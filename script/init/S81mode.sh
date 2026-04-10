#!/bin/sh

. /opt/muos/script/var/func.sh

HDMI_PATH=$(GET_VAR "device" "screen/hdmi")
BOARD_HDMI=$(GET_VAR "device" "board/hdmi")
DEVICE_MODE=$(GET_VAR "config" "boot/device_mode")

BRIGHT_ADV=$(GET_VAR "config" "settings/advanced/brightness")
BRIGHT_DEF=$(GET_VAR "config" "settings/general/brightness")
BRIGHT_MAX=$(GET_VAR "device" "screen/bright")

COLOUR_TEMP=$(GET_VAR "config" "settings/colour/temperature")
COLOUR_PATH=$(GET_VAR "device" "screen/colour")

if [ "${BOARD_HDMI:-0}" -eq 1 ]; then
	HDMI_VALUE=0
	[ -n "$HDMI_PATH" ] && [ -f "$HDMI_PATH" ] && IFS= read -r HDMI_VALUE <"$HDMI_PATH"

	case "$HDMI_VALUE" in
		1) CONSOLE_MODE=1 ;;
		*) CONSOLE_MODE=0 ;;
	esac

	SET_VAR "config" "boot/device_mode" "$CONSOLE_MODE"
	DEVICE_MODE="$CONSOLE_MODE"
fi

if [ "$DEVICE_MODE" -eq 1 ]; then
	/opt/muos/script/device/hdmi.sh &
else
	/opt/muos/script/device/bright.sh R

	case "$BRIGHT_ADV" in
		3) /opt/muos/script/device/bright.sh "$BRIGHT_MAX" ;;
		2) /opt/muos/script/device/bright.sh 90 ;;
		1) /opt/muos/script/device/bright.sh 35 ;;
		*) /opt/muos/script/device/bright.sh "$BRIGHT_DEF" ;;
	esac

	printf "%s" "$COLOUR_TEMP" >"$COLOUR_PATH"
	SET_VAR "config" "settings/hdmi/scan" "0"
fi
