#!/bin/sh

. /opt/muos/script/var/func.sh

NAME=$1
CORE=$2
FILE=${3%/}

(
	LOG_INFO "$0" 0 "Content Launch" "DETAIL"
	LOG_INFO "$0" 0 "NAME" "$NAME"
	LOG_INFO "$0" 0 "CORE" "$CORE"
	LOG_INFO "$0" 0 "FILE" "$FILE"
) &

HOME="$(GET_VAR "device" "board/home")"
export HOME

SETUP_SDL_ENVIRONMENT

SET_VAR "system" "foreground_process" "retroarch"

RA_CONF="/run/muos/storage/info/config/retroarch.cfg"
CONFIGURE_RETROARCH "$RA_CONF"

LOGPATH="$(GET_VAR "device" "storage/rom/mount")/MUOS/log/nxe.log"

echo "Starting Cave Story (libretro)" > "$LOGPATH"
# Set nxengine BIOS path
DOUK_BIOS="/run/muos/storage/bios/nxengine/Doukutsu.exe"

if [ -e "$DOUK_BIOS" ]; then
	echo "Doukutsu.exe found!" >> "$LOGPATH"
	GREENLIGHT=1

else
	echo "Doukutsu.exe NOT found!" >> "$LOGPATH"
	CZ_NAME="Cave Story (En).zip"
	CAVE_URL="https://bot.libretro.com/assets/cores/Cave Story/$CZ_NAME"
	echo "Cave Story URL: $CAVE_URL" >> "$LOGPATH"
	BIOS_FOLDER="/run/muos/storage/bios/"

	echo "$DOUK_BIOS not found in $BIOS_FOLDER"
	# Is this thing on(line)?
	check_internet() {
		echo "Pinging github.com" >> "$LOGPATH"
		ping -c 1 github.com >/dev/null 2>&1
		return $?
	}
	if check_internet; then
		# Download
		echo "Downloading from $CAVE_URL" >>"$LOGPATH"
		wget -O "$BIOS_FOLDER$CZ_NAME" "$CAVE_URL"
	
		# Extract
		echo "Extracting $CZ_NAME to $BIOS_FOLDER/Cave Story (En)" >> "$LOGPATH"
		unzip -o "$BIOS_FOLDER$CZ_NAME" -d "$BIOS_FOLDER"
		if [ -e "$BIOS_FOLDER/Cave Story (En)" ]; then
			echo "Renaming Cave Story (En) Folder to nxengine" >> "$LOGPATH"
			mv "$BIOS_FOLDER/Cave Story (En)" "$BIOS_FOLDER/nxengine"
			# Cleanup
			echo "Removing $CZ_NAME"
			rm -f "$BIOS_FOLDER$CZ_NAME"
			GREENLIGHT=1
		elif [ -e "$BIOS_FOLDER/nxengine" ]; then
			echo "Already renamed" >> "$LOGPATH"
			GREENLIGHT=1
		else
			echo "Did extraction fail?" >> "$LOGPATH"
		fi
	else
		echo "Unable to download $CZ_NAME" >> "$LOGPATH"
		GREENLIGHT=0
	fi
fi

if [ "$GREENLIGHT" -eq 1 ]; then
	echo "Launching Cave Story" >> "$LOGPATH"
	/opt/muos/script/mux/track.sh "$NAME" "$CORE" "$FILE" start

	nice --20 retroarch -v -c "$RA_CONF" -L "$(GET_VAR "device" "storage/rom/mount")/MUOS/core/$CORE" "$DOUK" &
	RA_PID=$!

	wait $RA_PID
	unset SDL_HQ_SCALER SDL_ROTATION SDL_BLITTER_DISABLED

	/opt/muos/script/mux/track.sh "$NAME" "$CORE" "$FILE" stop
fi

