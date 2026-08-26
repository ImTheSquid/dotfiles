#!/bin/sh

# Sketchybar provides $NAME (e.g. "space.3"), $SELECTED (true/false), $SENDER.
# We expect the item to also pass SPACE_DEFAULT_ICON via env (set in the
# script= property when the item is added).

if [ -n "$SELECTED" ]; then
  sketchybar --set "$NAME" background.drawing="$SELECTED"
fi

SID="${NAME##*.}"
DEFAULT_ICON="${SPACE_DEFAULT_ICON:-$SID}"

SPACE_JSON=$(yabai -m query --spaces --space "$SID" 2>/dev/null)
if [ -z "$SPACE_JSON" ]; then
  sketchybar --set "$NAME" icon="$DEFAULT_ICON" label=""
  exit 0
fi

YABAI_LABEL=$(printf '%s' "$SPACE_JSON" | jq -r '.label // ""')
NAME_TEXT="$DEFAULT_ICON"
[ -n "$YABAI_LABEL" ] && NAME_TEXT="$YABAI_LABEL"

COUNT=$(yabai -m query --windows --space "$SID" 2>/dev/null \
  | jq '[.[] | select(
        .["is-floating"]   == false and
        .["is-sticky"]     == false and
        .["is-minimized"]  == false and
        .["is-hidden"]     == false and
        (.["scratchpad"] // "") == ""
      )] | length')

# Render the window count as 8-dot braille: 4 dots per column, 2 columns per
# character (up to 8 windows per glyph). Fill column 1 top-to-bottom first.
DOTS=""
n=${COUNT:-0}
while [ "$n" -gt 0 ]; do
  if   [ "$n" -ge 8 ]; then DOTS="${DOTS}⣿"; n=$((n-8))
  elif [ "$n" -eq 7 ]; then DOTS="${DOTS}⡿"; n=0
  elif [ "$n" -eq 6 ]; then DOTS="${DOTS}⡟"; n=0
  elif [ "$n" -eq 5 ]; then DOTS="${DOTS}⡏"; n=0
  elif [ "$n" -eq 4 ]; then DOTS="${DOTS}⡇"; n=0
  elif [ "$n" -eq 3 ]; then DOTS="${DOTS}⠇"; n=0
  elif [ "$n" -eq 2 ]; then DOTS="${DOTS}⠃"; n=0
  else                      DOTS="${DOTS}⠁"; n=0
  fi
done

sketchybar --set "$NAME" icon="$NAME_TEXT" label="$DOTS"
