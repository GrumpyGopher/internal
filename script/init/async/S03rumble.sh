#!/bin/sh

. /opt/muos/script/var/func.sh

BOARD_NAME=$(GET_VAR "device" "board/name")
RUMBLE_PIN=$(GET_VAR "device" "board/rumble")

RUMBLE_SETTING=$(GET_VAR "config" "settings/advanced/rumble")

case "$BOARD_NAME" in
	mgx* | tui*)
		[ -e /sys/class/gpio/gpio227 ] || echo 227 >/sys/class/gpio/export
		echo out >/sys/class/gpio/gpio227/direction
		echo 0 >/sys/class/gpio/gpio227/value
		;;
	rk*)
		[ -e /sys/class/pwm/pwmchip0/pwm0 ] || echo 0 >/sys/class/pwm/pwmchip0/export
		echo 1000000 >/sys/class/pwm/pwmchip0/pwm0/period
		echo 1000000 >/sys/class/pwm/pwmchip0/pwm0/duty_cycle
		echo 1 >/sys/class/pwm/pwmchip0/pwm0/enable
		;;
	rg-vita*)
		[ -e /sys/class/pwm/pwmchip1/pwm0 ] || echo 0 >/sys/class/pwm/pwmchip1/export
		echo 100000 >/sys/class/pwm/pwmchip1/pwm0/period
		echo 100000 >/sys/class/pwm/pwmchip1/pwm0/duty_cycle
		echo 1 >/sys/class/pwm/pwmchip1/pwm0/enable
		;;
esac

LOG_INFO "$0" 0 "BOOTING" "Device Rumble Check"
case "$RUMBLE_SETTING" in 1 | 4 | 5) RUMBLE "$RUMBLE_PIN" 0.3 ;; esac
