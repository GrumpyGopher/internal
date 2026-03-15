#!/bin/sh

. /opt/muos/script/var/func.sh

PF_INTERNAL=$(GET_VAR "device" "audio/pf_internal")
PF_EXTERNAL=$(GET_VAR "device" "audio/pf_external")

READY=$(GET_VAR "device" "audio/ready")

BOOT_CONSOLE_MODE=$(GET_VAR "config" "boot/device_mode")
HDMI_INTERNAL_AUDIO=$(GET_VAR "config" "settings/hdmi/audio")

ADV_VOL=$(GET_VAR "config" "settings/advanced/volume")
ADV_OD=$(GET_VAR "config" "settings/advanced/overdrive")
ADV_AR=$(GET_VAR "config" "settings/advanced/audio_ready")

DBUS_SOCKET="/run/dbus/system_bus_socket"
PW_SOCKET="/run/pipewire-0"

TIMEOUT=3000
INTERVAL=100

SOCKET_READY() {
	[ -S "$PW_SOCKET" ] || return 1
	pw-cli info || return 1
	return 0
}

PROC_GONE() {
	NAME=$1

	ELAPSED=0
	while pgrep -x "$NAME"; do
		sleep 0.1
		ELAPSED=$((ELAPSED + INTERVAL))
		[ "$ELAPSED" -ge "$TIMEOUT" ] && return 1
	done

	return 0
}

RESTORE_CONF() {
	SRC=$1
	DST=$2

	[ -f "$SRC" ] || return 1
	[ -f "$DST" ] && cmp -s "$SRC" "$DST" && return 0
	cp -f "$SRC" "$DST"
}

GET_NODE_ID() {
	pw-dump | jq -r '.[] | select(.type=="PipeWire:Interface:Node") | "\(.id) \(.info.props["node.name"])"' |
		awk -v target="$1" '$0 ~ target {print $1; exit}'
}

GET_TARGET_NODE() {
	if [ "$BOOT_CONSOLE_MODE" -eq 1 ]; then
		TARGET_ID="$PF_EXTERNAL"
		[ "$HDMI_INTERNAL_AUDIO" -eq 1 ] && TARGET_ID="$PF_INTERNAL"
	else
		TARGET_ID="$PF_INTERNAL"
	fi

	ELAPSED=0
	while [ "$ELAPSED" -lt "$TIMEOUT" ]; do
		pw-dump | grep -q "$TARGET_ID" && break
		sleep 0.1
		ELAPSED=$((ELAPSED + INTERVAL))
	done

	printf "%s\n" "$TARGET_ID"
}

GET_BOOT_RUNTIME_PERCENT() {
	case "$ADV_VOL" in
		3) V=100 ;;
		2) V=35 ;;
		1) V=0 ;;
		*) V= ;;
	esac

	if [ "$BOOT_CONSOLE_MODE" -eq 1 ]; then
		if [ "${ADV_OD:-0}" -eq 1 ]; then
			V=200
		else
			V=100
		fi
	fi

	printf "%s\n" "$V"
}

FINALISE_AUDIO() {
	TARGET_ID=$(GET_TARGET_NODE)
	DEF_ID=""
	RUNTIME_PERCENT=$(GET_BOOT_RUNTIME_PERCENT)

	ELAPSED=0
	while [ -z "$DEF_ID" ]; do
		DEF_ID=$(GET_NODE_ID "$TARGET_ID")
		[ -n "$DEF_ID" ] && break
		sleep 0.1
		ELAPSED=$((ELAPSED + INTERVAL))
		[ "$ELAPSED" -ge "$TIMEOUT" ] && break
	done

	if [ -z "$DEF_ID" ]; then
		LOG_WARN "$0" 0 "PIPEWIRE" "$(printf "No matching PipeWire node for target '%s' after timeout" "$TARGET_ID")"
		[ "$ADV_AR" -eq 1 ] && SET_VAR "device" "audio/ready" "1"
		return 1
	fi

	wpctl set-default "$DEF_ID" || {
		LOG_WARN "$0" 0 "PIPEWIRE" "$(printf "Unable to set default node '%s'" "$DEF_ID")"
	}

	sleep 0.1
	wpctl set-mute @DEFAULT_AUDIO_SINK@ 0

	if [ -n "$RUNTIME_PERCENT" ]; then
		wpctl set-volume @DEFAULT_AUDIO_SINK@ "${RUNTIME_PERCENT}%"

		case "$ADV_VOL" in
			1) SET_SAVED_AUDIO_VOLUME 0 ;;
			2) SET_SAVED_AUDIO_VOLUME 35 ;;
			3) SET_SAVED_AUDIO_VOLUME "$(GET_VAR "device" "audio/max")" ;;
			*) ;;
		esac
	else
		SAVED_VOL=$(GET_SAVED_AUDIO_VOLUME)
		wpctl set-volume @DEFAULT_AUDIO_SINK@ "${SAVED_VOL}%"
		LOG_INFO "$0" 0 "PIPEWIRE" "$(printf "Restored saved volume: %s%%" "$SAVED_VOL")"
	fi

	[ "$ADV_AR" -eq 1 ] && SET_VAR "device" "audio/ready" "1"

	LOG_SUCCESS "$0" 0 "PIPEWIRE" "$(printf "Audio Finalised (node=%s%s)" "$DEF_ID" "$([ -n "$RUNTIME_PERCENT" ] && printf ", runtime=%s%%" "$RUNTIME_PERCENT")")"
	return 0
}

START_PIPEWIRE() {
	RESTORE_CONF "$MUOS_SHARE_DIR/conf/wireplumber.lua" "/usr/share/wireplumber/main.lua.d/60-muos-wireplumber.lua"

	if ! pgrep -x "pipewire"; then
		LOG_INFO "$0" 0 "PIPEWIRE" "$(printf "Starting PipeWire (runtime: %s)" "$PIPEWIRE_RUNTIME_DIR")"
		chrt -f 88 pipewire -c "$MUOS_SHARE_DIR/conf/pipewire.conf" &
	else
		LOG_WARN "$0" 0 "PIPEWIRE" "PipeWire already running"
	fi

	if ! pgrep -x "wireplumber"; then
		LOG_INFO "$0" 0 "PIPEWIRE" "Starting WirePlumber..."
		wireplumber &
	else
		LOG_WARN "$0" 0 "PIPEWIRE" "WirePlumber already running"
	fi

	return 0
}

WAIT_FOR_DBUS() {
	ELAPSED=0

	while [ ! -S "$DBUS_SOCKET" ]; do
		sleep 0.1
		ELAPSED=$((ELAPSED + INTERVAL))
		[ "$ELAPSED" -ge "$TIMEOUT" ] && return 1
	done

	return 0
}

WAIT_FOR_PIPEWIRE() {
	TARGET_ID=$(GET_TARGET_NODE)
	ELAPSED=0

	while [ "$ELAPSED" -lt "$TIMEOUT" ]; do
		if SOCKET_READY; then
			pw-dump 2>/dev/null | grep -q "$TARGET_ID" && return 0
		fi
		sleep 0.1
		ELAPSED=$((ELAPSED + INTERVAL))
	done

	LOG_WARN "$0" 0 "PIPEWIRE" "$(printf "Target node '%s' not ready after timeout" "$TARGET_ID")"
	return 1
}

DO_START() {
	[ "$ADV_AR" -eq 1 ] && SET_VAR "device" "audio/ready" "0"

	if ! START_PIPEWIRE; then
		LOG_ERROR "$0" 0 "PIPEWIRE" "Failed to start"
		[ "$ADV_AR" -eq 1 ] && SET_VAR "device" "audio/ready" "1"
		exit 1
	fi

	LOG_INFO "$0" 0 "PIPEWIRE" "Restoring Default Sound System"
	RESTORE_CONF "$MUOS_SHARE_DIR/conf/asound.conf" "/etc/asound.conf"

	LOG_INFO "$0" 0 "PIPEWIRE" "ALSA Config Restoring"
	RESTORE_CONF "$MUOS_SHARE_DIR/conf/alsa.conf" "/usr/share/alsa/alsa.conf"

	LOG_INFO "$0" 0 "PIPEWIRE" "Restoring Audio State"
	alsactl -U -f "$DEVICE_CONTROL_DIR/asound.state" restore

	RESET_MIXER

	if WAIT_FOR_DBUS; then
		LOG_SUCCESS "$0" 0 "PIPEWIRE" "D-Bus socket is available"
	else
		LOG_WARN "$0" 0 "PIPEWIRE" "D-Bus not ready after timeout; proceeding"
	fi

	if ! WAIT_FOR_PIPEWIRE; then
		LOG_WARN "$0" 0 "PIPEWIRE" "PipeWire socket not ready after timeout"
		[ "$ADV_AR" -eq 1 ] && SET_VAR "device" "audio/ready" "1"
		exit 1
	fi

	# Prevent loud pop or incorrect gain during restore
	wpctl set-mute @DEFAULT_AUDIO_SINK@ 1

	SET_SAVED_AUDIO_VOLUME "$(GET_SAVED_AUDIO_VOLUME)"
	FINALISE_AUDIO

	exit 0
}

DO_STOP() {
	LOG_INFO "$0" 0 "PIPEWIRE" "Audio shutdown sequence..."

	wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%

	for PROC in pipewire wireplumber; do
		pkill -15 "$PROC" 2>/dev/null
		PROC_GONE "$PROC" || pkill -9 "$PROC" 2>/dev/null
	done

	[ "$ADV_AR" -eq 1 ] && SET_VAR "device" "audio/ready" "0"
	LOG_SUCCESS "$0" 0 "PIPEWIRE" "Audio shutdown complete"
}

DO_RELOAD() {
	LOG_INFO "$0" 0 "PIPEWIRE" "Reloading audio routing/volume"

	if SOCKET_READY; then
		if FINALISE_AUDIO; then
			LOG_SUCCESS "$0" 0 "PIPEWIRE" "Reload complete"
			exit 0
		fi
	fi

	LOG_WARN "$0" 0 "PIPEWIRE" "Reload incomplete (daemon/socket not ready)"
	exit 1
}

PRINT_STATUS() {
	SOCK=0
	SINK=0
	PW_RUNNING=0
	WP_RUNNING=0

	SOCKET_READY && SOCK=1
	pw-cli ls Node 2>/dev/null | grep -q "Audio/Sink" && SINK=1
	pgrep -x "pipewire" >/dev/null 2>&1 && PW_RUNNING=1
	pgrep -x "wireplumber" >/dev/null 2>&1 && WP_RUNNING=1

	DEF_SINK=$(wpctl status 2>/dev/null | awk -F': ' '/Default Sink:/ {print $2; exit}')
	PW_PID=$(pgrep -xo pipewire)
	WP_PID=$(pgrep -xo wireplumber)

	printf "PipeWire:\t\t%s\n" "$([ "$PW_RUNNING" -eq 1 ] && printf "running\t\t%s" "$PW_PID" || printf "stopped")"
	printf "WirePlumber:\t\t%s\n" "$([ "$WP_RUNNING" -eq 1 ] && printf "running\t\t%s" "$WP_PID" || printf "stopped")"
	printf "Socket:\t\t\t%s\n" "$([ "$SOCK" -eq 1 ] && printf "ready\t\t%s" "$PW_SOCKET" || printf "not ready")"
	printf "Audio Sink:\t\t%s%s\n" "$([ "$SINK" -eq 1 ] && printf "available" || printf "missing")" "$([ -n "$DEF_SINK" ] && printf " (default: %s)" "$DEF_SINK" || printf "")"
	printf "MustardOS Ready:\t%s\n" "$([ "$READY" = "1" ] && printf "yes" || printf "no")"

	[ "$PW_RUNNING" -eq 1 ] && [ "$SOCK" -eq 1 ] && [ "$SINK" -eq 1 ] && return 0
	[ "$PW_RUNNING" -eq 0 ] && [ "$WP_RUNNING" -eq 0 ] && return 3

	return 1
}

case "$1" in
	start) DO_START ;;
	stop) DO_STOP ;;
	restart)
		DO_STOP
		DO_START
		;;
	reload) DO_RELOAD ;;
	status)
		if PRINT_STATUS; then
			exit 0
		else
			EC=$?
			exit "$EC"
		fi
		;;
	*)
		printf "Usage: %s {start|stop|restart|reload|status}\n" "$0"
		exit 1
		;;
esac
