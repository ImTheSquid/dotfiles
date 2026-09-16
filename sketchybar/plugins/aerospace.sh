#!/bin/sh

# Drives every space.N chip in one pass. Sketchybar provides $SENDER; the
# workspace-change trigger also passes FOCUSED_WORKSPACE. SPACE_COUNT comes
# from the item's script= property.
#
# Two aerospace calls and one sketchybar call per refresh, regardless of how
# many chips there are -- a per-chip script would be that many of each.

AEROSPACE=/opt/homebrew/bin/aerospace

FOCUSED="${FOCUSED_WORKSPACE:-$($AEROSPACE list-workspaces --focused 2>/dev/null)}"
# AeroSpace isn't answering yet (login race, or it's not running). Leave the
# bar as it is rather than blanking every chip.
[ -z "$FOCUSED" ] && exit 0

# One window list, counted per workspace, instead of one query per chip.
COUNTS=$($AEROSPACE list-windows --all --format '%{workspace}' 2>/dev/null | sort | uniq -c)

# Render a window count as 8-dot braille: 4 dots per column, 2 columns per
# character (up to 8 windows per glyph). Fill column 1 top-to-bottom first.
dots() {
  d=""
  n=$1
  while [ "$n" -gt 0 ]; do
    if   [ "$n" -ge 8 ]; then d="${d}⣿"; n=$((n-8))
    elif [ "$n" -eq 7 ]; then d="${d}⡿"; n=0
    elif [ "$n" -eq 6 ]; then d="${d}⡟"; n=0
    elif [ "$n" -eq 5 ]; then d="${d}⡏"; n=0
    elif [ "$n" -eq 4 ]; then d="${d}⡇"; n=0
    elif [ "$n" -eq 3 ]; then d="${d}⠇"; n=0
    elif [ "$n" -eq 2 ]; then d="${d}⠃"; n=0
    else                      d="${d}⠁"; n=0
    fi
  done
  printf '%s' "$d"
}

sid=1
set --
while [ "$sid" -le "${SPACE_COUNT:-10}" ]; do
  n=$(printf '%s\n' "$COUNTS" | awk -v w="$sid" '$2 == w { print $1 }')
  if [ "$sid" = "$FOCUSED" ]; then draw=on; else draw=off; fi
  set -- "$@" --set "space.$sid" "background.drawing=$draw" "label=$(dots "${n:-0}")"
  sid=$((sid+1))
done

sketchybar "$@"
