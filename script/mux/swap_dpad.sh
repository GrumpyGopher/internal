#!/bin/sh

. /opt/muos/script/var/func.sh

if [ "$(GET_VAR "device" "board/stick")" -eq 0 ] && [ "$(GET_VAR "config" "settings/advanced/dpad_swap")" -eq 1 ]; then
	RUMBLE_DEVICE="$(GET_VAR "device" "board/rumble")"
	DPAD_SWAP=$(GET_VAR "device" "input/swap")

	case "$(GET_VAR "system" "foreground_process")" in
		mux*) ;;
		*)
			case "$(GET_VAR "device" "board/name")" in
				rg*)
					case "$(cat "$DPAD_SWAP")" in
						0)
							echo 2 >"$DPAD_SWAP"
							RUMBLE "$RUMBLE_DEVICE" .1
							;;
						2)
							echo 0 >"$DPAD_SWAP"
							RUMBLE "$RUMBLE_DEVICE" .1
							sleep 0.1
							RUMBLE "$RUMBLE_DEVICE" .1
							;;
					esac
					;;
				tui*)
					if [ -e "$DPAD_SWAP" ]; then
						rm -f "$DPAD_SWAP"
						RUMBLE "$RUMBLE_DEVICE" .1
					else
						touch "$DPAD_SWAP"
						RUMBLE "$RUMBLE_DEVICE" .1
						sleep 0.1
						RUMBLE "$RUMBLE_DEVICE" .1
					fi
					;;
			esac
			;;
	esac
fi
