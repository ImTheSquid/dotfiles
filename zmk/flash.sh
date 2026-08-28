#!/usr/bin/env bash
# Copy a built .uf2 to the controller. Double-tap reset first to mount NICENANO.
# Usage: ./flash.sh [left|right]   (default: left)
set -euo pipefail

WS="${ZMK_WORKSPACE:-$HOME/zmk-workspace}"
SIDE="${1:-left}"
UF2="$WS/splitkb_aurora_corne_$SIDE.uf2"

[ -f "$UF2" ] || { echo "missing $UF2 — run ./build.sh $SIDE first" >&2; exit 1; }

echo "waiting for NICENANO (double-tap the reset button)..."
for _ in $(seq 60); do
  [ -d /Volumes/NICENANO ] && break
  sleep 1
done
[ -d /Volumes/NICENANO ] || { echo "NICENANO never mounted" >&2; exit 1; }

cp "$UF2" /Volumes/NICENANO/
sync
echo "flashed $SIDE"
