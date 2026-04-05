#!/bin/sh

. /opt/muos/script/var/func.sh

GOVERNOR=$(GET_VAR "device" "cpu/governor")

WIDTH=$(GET_VAR "device" "screen/internal/width")
HEIGHT=$(GET_VAR "device" "screen/internal/height")

LOG_INFO "$0" 0 "BOOTING" "Setting 'performance' Governor"
echo "performance" >"$GOVERNOR"

[ -f "$LED_CONTROL_SCRIPT" ] && "$LED_CONTROL_SCRIPT" 1 0 0 0 0 0 0 0

mkdir -p "/tmp/muos"
rm -rf "$MUOS_LOG_DIR"/*.log "/opt/muxtmp"

read -r MU_UPTIME _ </proc/uptime
SET_VAR "system" "resume_uptime" "$MU_UPTIME"
SET_VAR "system" "idle_inhibit" "0"
SET_VAR "config" "boot/device_mode" "0"
SET_VAR "device" "audio/ready" "0"

LOG_INFO "$0" 0 "BOOTING" "Setting OS Release"
/opt/muos/script/system/os_release.sh &

echo 1 >"$MUOS_RUN_DIR/work_led_state"
: >"$MUOS_RUN_DIR/net_start"

LOG_INFO "$0" 0 "BOOTING" "Reset temporary screen rotation and zoom"
SCREEN_DIR="/opt/muos/device/config/screen"
rm -f "$SCREEN_DIR/s_rotate" "$SCREEN_DIR/s_zoom" &

LOG_INFO "$0" 0 "BOOTING" "Restoring Screen Mode"
SET_VAR "device" "screen/width" "$WIDTH" &
SET_VAR "device" "screen/height" "$HEIGHT" &
SET_VAR "device" "mux/width" "$WIDTH" &
SET_VAR "device" "mux/height" "$HEIGHT" &
