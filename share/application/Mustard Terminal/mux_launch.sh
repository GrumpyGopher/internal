#!/bin/sh
# HELP: A virtual terminal for direct shell access, be careful out there!
# ICON: terminal
# GRID: Terminal

. /opt/muos/script/var/func.sh

APP_BIN="muterm"
SETUP_APP "$APP_BIN" ""

# -----------------------------------------------------------------------------

cd "$HOME" || exit

# TODO: Use the variables from the theme if found, will also have
# TODO: adjust for high DPI devices like the Brick and Vita Pro...
/opt/muos/frontend/muterm -s 15 --font-hinting mono
