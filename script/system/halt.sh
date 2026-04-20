#!/bin/sh

. /opt/muos/script/var/func.sh

BOARD_NAME=$(GET_VAR "device" "board/name")
RUMBLE_DEVICE="$(GET_VAR "device" "board/rumble")"
RUMBLE_SETTING="$(GET_VAR "config" "settings/advanced/rumble")"

# muOS shutdown/reboot script. This behaves a bit better than BusyBox
# poweroff/reboot commands, which also make some odd choices (e.g., unmounting
# disks before killing processes, so running programs can't save state).

USAGE() {
	printf 'Usage: %s {poweroff|reboot}\n' "$0" >&2
	exit 1
}

# We pass our arguments along to halt_internal.sh, which forwards extra args to
# killall5. In particular, we can append `-o PID` arguments to avoid killing
# specific processes too early in the sequence.
[ "$#" -eq 1 ] || USAGE

case "$1" in
	poweroff | reboot) ;;
	*) USAGE ;;
esac

# Omit various programs from the termination process.
# FUSE filesystems (e.g., exFAT) would unmount in parallel with other programs
# exiting, preventing them from writing state to the SD card during cleanup.
for OMIT_PID in $(pidof /opt/muos/frontend/muterm /sbin/mount.exfat-fuse 2>/dev/null); do
	set -- "$@" -o "$OMIT_PID"
done

# We kill processes using killall5, which sends signals to processes outside
# the current session. We might miss killing some processes since we don't know
# anything about the session we're started in.
#
# We address this by wrapping the actual shutdown sequence in a setsid command,
# ensuring we invoke killall5 from a new, empty session.
#
# Use -f to always fork a new process, even if it would possible for the
# current process to become a session leader directly. This prevents our parent
# process from "helpfully" trying to kill us when it terminates.
#
# Use -w to wait for halt_internal.sh to terminate so we can return an
# appropriate exit status if the shutdown fails partway through.
#
# Runs an external command and waits for it to finish or a timeout to expire.
# If the timeout expires, sends SIGTERM to the program and waits a bit more
# before sending SIGKILL if it still hasn't exited.
#
# Usage: RUN_WITH_TIMEOUT TERM_SEC KILL_SEC DESCRIPTION CMD [ARG]...
RUN_WITH_TIMEOUT() {
	TERM_SEC=$1
	KILL_SEC=$2
	DESCRIPTION=$3
	shift 3

	printf 'Running %s...\n' "$DESCRIPTION"

	"$@" &
	CMD_PID=$!

	(
		sleep "$TERM_SEC"
		if kill -0 "$CMD_PID" 2>/dev/null; then
			kill -TERM "$CMD_PID" 2>/dev/null
			sleep "$KILL_SEC"
			kill -KILL "$CMD_PID" 2>/dev/null
		fi
	) &
	WATCHDOG_PID=$!

	wait "$CMD_PID"
	STATUS=$?

	# Cancel the watchdog if the command already exited cleanly.
	kill "$WATCHDOG_PID" 2>/dev/null
	wait "$WATCHDOG_PID" 2>/dev/null

	if [ "$STATUS" -gt 128 ]; then
		printf 'Killed %s after timeout\n' "$DESCRIPTION"
	fi

	return "$STATUS"

}

# Prints a space-separated list of running process command names using the same
# criteria as killall5. Returns success if at least one such process is found.
#
# Usage: FIND_PROCS [-o OMIT_PID]...
FIND_PROCS() {
	CURRENT_SID=$(cut -d ' ' -f 6 /proc/self/stat)
	OMIT_PIDS=""
	while [ "$#" -gt 0 ]; do
		case "$1" in
			-o)
				shift
				OMIT_PIDS="$OMIT_PIDS $1"
				shift
				;;
			*) shift ;;
		esac
	done

	_FIND_PROCS_TMP=$(mktemp) || return 1

	ps -eo pid=,sid=,comm= | while read -r PID SID COMM; do
		[ "$PID" -eq 1 ] && continue
		[ "$SID" -eq 0 ] && continue
		[ "$SID" -eq "$CURRENT_SID" ] && continue

		for O in $OMIT_PIDS; do
			[ "$PID" -eq "$O" ] && continue 2
		done

		printf '%s ' "$COMM" >>"$_FIND_PROCS_TMP"
	done

	FOUND=$(cat "$_FIND_PROCS_TMP")
	rm -f "$_FIND_PROCS_TMP"

	[ -n "$FOUND" ] && {
		printf '%s\n' "$FOUND"
		return 0
	}

	return 1

}

# Sends the specified termination signal to every process outside the current
# session, then waits the specified number of seconds for those processes to
# exit. Rechecks every 250ms to see if they have all died yet.
#
# Usage: KILL_AND_WAIT TIMEOUT_SEC SIGNAL [-o OMIT_PID]...

KILL_AND_WAIT() {
	TIMEOUT_SEC=$1
	SIGNAL=$2
	shift 2

	printf 'Sending SIG%s to processes...\n' "$SIGNAL"
	killall5 "-$SIGNAL" "$@"

	printf 'Waiting for processes to terminate: '
	i=0
	MAX=$((TIMEOUT_SEC * 4))

	while [ "$i" -lt "$MAX" ]; do
		PROCS=$(FIND_PROCS "$@")
		[ -z "$PROCS" ] && {
			printf 'done\n'
			return 0
		}
		sleep 0.25
		i=$((i + 1))
	done

	printf 'timed out\nStill running: %s\n' "$PROCS"
	return 1

}

LOG_INFO "$0" 0 "HALT" "Stopping muX services"
MUXCTL stop

# Avoid hangups from syncthing if it's running.
LOG_INFO "$0" 0 "HALT" "Stopping Syncthing"
TERMINATE_SYNCTHING

LOG_INFO "$0" 0 "HALT" "Stopping web services"
/opt/muos/script/web/service.sh stopall >/dev/null 2>&1

if pgrep '^mux' >/dev/null 2>&1; then
	LOG_INFO "$0" 0 "HALT" "Killing muX modules"
	while :; do
		PIDS=$(pgrep '^mux') || break

		for PID in $PIDS; do
			kill -9 "$PID" 2>/dev/null
		done

		sleep 0.1
	done
fi

# Check if random theme is enabled and run the random theme script if necessary
if [ "$(GET_VAR "config" "settings/advanced/random_theme")" -eq 1 ] 2>/dev/null; then
	printf 'Random theme is enabled. Changing to a random theme...\n'
	/opt/muos/script/package/theme.sh install "?R"
fi

LOG_INFO "$0" 0 "HALT" "Stopping USB Function"
/opt/muos/script/system/usb_gadget.sh stop

LOG_INFO "$0" 0 "HALT" "Disabling any swapfile mounts"
swapoff -a

LOG_INFO "$0" 0 "HALT" "Syncing RTC to hardware"
hwclock --systohc --utc

LOG_INFO "$0" 0 "HALT" "Unloading kernel modules"
/opt/muos/script/device/module.sh unload

LOG_INFO "$0" 0 "HALT" "Reset the used reset variable"
SET_VAR "system" "used_reset" 0

# Stop system services. If shutdown scripts are still running after
# 10s, SIGTERM them, then wait 5s more before resorting to SIGKILL.
LOG_INFO "$0" 0 "HALT" "Stopping system services"
RUN_WITH_TIMEOUT 10 5 'shutdown scripts' /etc/init.d/rcK

# Send SIGTERM to remaining processes. Wait up to 10s before mopping up
# with SIGKILL, then wait up to 1s more for everything to die.
LOG_INFO "$0" 0 "HALT" "Terminating remaining processes"
if ! KILL_AND_WAIT 10 TERM "$@"; then
	KILL_AND_WAIT 1 KILL "$@"
fi

# Vibrate the device if the user has specifically set it on shutdown
case "$RUMBLE_SETTING" in
	2 | 4 | 6)
		LOG_INFO "$0" 0 "HALT" "Running shutdown rumble"
		RUMBLE "$RUMBLE_DEVICE" 0.3
		;;
esac

# Sync filesystems before beginning the standard halt sequence. If a
# subsequent step hangs (or the user hard resets), syncing here reduces
# the likelihood of corrupting muOS configs, RetroArch autosaves, etc.
LOG_INFO "$0" 0 "HALT" "Syncing writes to disk..."
sync

LOG_INFO "$0" 0 "HALT" "Unmounting storage devices..."
umount -ar

"$1" -f

case "$BOARD_NAME" in
	rg*) echo 0x1801 >"/sys/class/axp/axp_reg" ;;
esac
