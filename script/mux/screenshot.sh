#!/bin/sh

. /opt/muos/script/var/func.sh

SS_LOCK="/tmp/screenshot.lock"

if [ ! -e "$SS_LOCK" ]; then
	touch "$SS_LOCK"
	trap 'rm -f "$SS_LOCK"' EXIT INT TERM

	RUMBLE "$(GET_VAR "device" "board/rumble")" 0.3

	BASE_DIR="$MUOS_STORE_DIR/screenshot"
	CURRENT_DATE="$(date +"%Y%m%d_%H%M")"
	INDEX=0

	while :; do
		SS_FILE="${BASE_DIR}/muOS_${CURRENT_DATE}_${INDEX}.png"
		[ ! -f "$SS_FILE" ] && break
		INDEX=$((INDEX + 1))
	done

	# Silly 28xx...
	case "$(GET_VAR "device" "board/name")" in
		mgx*) /opt/muos/frontend/mufbset -g "$SS_FILE" && convert "$SS_FILE" -rotate 270 "$SS_FILE" ;;
		rg28xx-h) /opt/muos/frontend/mufbset -g "$SS_FILE" && convert "$SS_FILE" -rotate 90 "$SS_FILE" ;;
		*) /opt/muos/frontend/mufbset -g "$SS_FILE" ;;
	esac
fi
