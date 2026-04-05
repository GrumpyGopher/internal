#!/bin/sh

. /opt/muos/script/var/func.sh

[ "$FACTORY_RESET" -eq 1 ] && exit 0

mount -t configfs none /sys/kernel/config &

# A special case for the Zero28 device since it has to load the FUSE module
# manually, we'll just sit tight and wait for at least 10 seconds...
case "$BOARD_NAME" in
	mgx*)
		ELAPSED=0
		while [ ! -d "/sys/module/fuse" ]; do
			ELAPSED=$((ELAPSED + 1))
			[ "$ELAPSED" -ge 100 ] && break
			sleep 0.1
		done
		;;
esac

# These scripts return as soon as the necessary mounts are available, but also
# leave background jobs running that respond to future media add/remove events.
/opt/muos/script/device/storage.sh "rom" "mount" 1 &
ROM_PID=$!

/opt/muos/script/device/storage.sh "sdcard" "mount" 1 &
SD_PID=$!

# Going to comment this out for now, it seems not everyone is interested in
# USB mounting and perhaps we could add this functionality somewhere else?
# /opt/muos/script/device/storage.sh "usb" "mount" 1 &

# Wait only for the mounts required by the boot process to become available
wait $ROM_PID $SD_PID

# Set up bind mounts under /run/muos/storage. Creates /run/muos/storage/mounted
# upon completion to unblock the rest of the boot process.
/opt/muos/script/device/bind.sh &

# Mount boot partition and start watching for USB storage. These aren't needed
# by the rest of the boot process, so handle them after bind mounts are set up.
(
	BOOT_DEV="$(GET_VAR "device" "storage/boot/dev")"
	BOOT_SEP="$(GET_VAR "device" "storage/boot/sep")"
	BOOT_NUM="$(GET_VAR "device" "storage/boot/num")"
	BOOT_TYPE="$(GET_VAR "device" "storage/boot/type")"
	BOOT_MOUNT="$(GET_VAR "device" "storage/boot/mount")"

	DEVICE="${BOOT_DEV}${BOOT_SEP}${BOOT_NUM}"

	if mount -t "$BOOT_TYPE" -o rw,utf8,noatime,nofail "/dev/$DEVICE" "$BOOT_MOUNT"; then
		SET_VAR "device" "storage/boot/active" "1"
		SET_VAR "device" "storage/boot/label" "$(blkid -o value -s LABEL "/dev/$DEVICE")"
	fi
) &

LOG_INFO "$0" 0 "BOOTING" "Checking for Safety Script"
OOPS="$ROM_MOUNT/oops.sh"
[ -x "$OOPS" ] && "$OOPS" && rm -f "$OOPS"

USER_INIT=$(GET_VAR "config" "settings/advanced/user_init")

if [ "${USER_INIT:-0}" -eq 1 ]; then
	LOG_INFO "$0" 0 "BOOTING" "Starting User Initialisation Scripts"
	/opt/muos/script/system/user_init.sh &
fi
