#!/bin/sh

. /opt/muos/script/var/func.sh

LOG_INFO "$0" 0 "BOOTING" "Removing Existing Update Scripts"
rm -rf "/opt/update.sh"

LOG_INFO "$0" 0 "BOOTING" "Starting Battery Watchdog"
BATTERY start

if [ "${CONSOLE_MODE:-0}" -eq 0 ]; then
	LOG_INFO "$0" 0 "BOOTING" "Detecting Charge Mode"
	/opt/muos/script/device/charge.sh
	LED_CONTROL_CHANGE
fi

if [ "$(GET_VAR "config" "boot/factory_reset")" -eq 1 ]; then
	LED_CONTROL_CHANGE &

	/opt/muos/script/system/factory.sh
	/opt/muos/script/system/halt.sh reboot

	exit 0
fi

LOG_INFO "$0" 0 "BOOTING" "Starting Hotkey Daemon"
HOTKEY start

LOG_INFO "$0" 0 "BOOTING" "Starting muX Frontend"
FRONTEND start

LOG_INFO "$0" 0 "BOOTING" "Bringing Up 'localhost' Network"
ifconfig lo up &

LOG_INFO "$0" 0 "BOOTING" "Connecting Network on Boot if requested and possible"
HAS_NETWORK=$(GET_VAR "device" "board/network")
CONNECT_ON_BOOT=$(GET_VAR "config" "settings/network/boot")
if [ "${HAS_NETWORK:-0}" -eq 1 ] && [ "${CONNECT_ON_BOOT:-0}" -eq 1 ]; then
	NET_ASYNC=$(GET_VAR "config" "settings/network/async_load")
	if [ "${NET_ASYNC:-0}" -eq 1 ]; then
		/opt/muos/script/system/network.sh connect &
	else
		/opt/muos/script/system/network.sh connect
	fi
fi

LOG_INFO "$0" 0 "BOOTING" "Checking Swap Requirements"
/opt/muos/script/system/swap.sh &

LOG_INFO "$0" 0 "BOOTING" "Precaching Content Mounts"
(
	SD1_MOUNT="$(GET_VAR "device" "storage/rom/mount")"
	SD2_MOUNT="$(GET_VAR "device" "storage/sdcard/mount")"
	USB_MOUNT="$(GET_VAR "device" "storage/usb/mount")"

	for STORAGE_MOUNT in $SD1_MOUNT $SD2_MOUNT $USB_MOUNT; do
		[ -d "$STORAGE_MOUNT/ROMS" ] || continue

		find "$STORAGE_MOUNT/ROMS" -maxdepth 2 -type d >/dev/null
		nice -n 19 ionice -c3 find "$STORAGE_MOUNT/ROMS" -maxdepth 4 >/dev/null
	done
) &

LOG_INFO "$0" 0 "BOOTING" "Storage Authenticity Check"
/opt/muos/script/system/checkmsd.sh &

LOG_INFO "$0" 0 "BOOTING" "Purging Old Logs"
LOG_CLEANER &

LOG_INFO "$0" 0 "BOOTING" "Starting Low Power Indicator"
/opt/muos/script/system/lowpower.sh &

USB_FUNCTION=$(GET_VAR "config" "settings/advanced/usb_function")
if [ "$USB_FUNCTION" -ne 0 ]; then
	LOG_INFO "$0" 0 "BOOTING" "Starting USB Function"
	/opt/muos/script/system/usb_gadget.sh start &
fi

LOG_INFO "$0" 0 "BOOTING" "Setting Device Controls"
FIRST_INIT=$(GET_VAR "config" "boot/first_init")
if [ "$FIRST_INIT" -eq 0 ]; then
	/opt/muos/script/device/control.sh FORCE_COPY &
else
	/opt/muos/script/device/control.sh &
fi

LOG_INFO "$0" 0 "BOOTING" "Setting up SDL Controller Map"
/opt/muos/script/mux/sdl_map.sh &

LOG_INFO "$0" 0 "BOOTING" "Running Catalogue Generator"
/opt/muos/script/system/catalogue.sh &

RA_CACHE=$(GET_VAR "config" "settings/advanced/retrocache")
if [ "${RA_CACHE:-0}" -eq 1 ]; then
	LOG_INFO "$0" 0 "BOOTING" "Precaching RetroArch System"
	ionice -c idle /opt/muos/bin/vmtouch -tfb "$MUOS_SHARE_DIR/conf/preload.txt" &
fi

LOG_INFO "$0" 0 "BOOTING" "Saving Kernel Boot Log"
ROM_MOUNT=$(GET_VAR "device" "storage/rom/mount")
dmesg >"$ROM_MOUNT/MUOS/log/dmesg/dmesg__$(date +"%Y_%m_%d__%H_%M_%S").log" &

[ "$FIRST_INIT" -eq 0 ] && SET_VAR "config" "boot/first_init" "1"
