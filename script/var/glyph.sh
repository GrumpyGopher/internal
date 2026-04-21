#!/bin/sh

GLYPH_DIR="/opt/muos/share/theme/MustardOS/sixel"
# TODO: Update this to current theme, once we start utilising Sixel properly...

GLYPH() {
	SIXEL="$GLYPH_DIR/$1.six"

	if [ -f "$SIXEL" ]; then
		cat "$SIXEL"
	else
		printf "[%s]" "$1"
	fi

	unset SIXEL
}

GLYPH_PRINT() {
	GLYPH "$1"
	printf " %s\n" "$2"
}

GLYPH_INLINE() {
	GLYPH "$1"
	printf " %s" "$2"
}
