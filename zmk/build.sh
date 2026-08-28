#!/usr/bin/env bash
# Build firmware. Usage: ./build.sh [left|right]   (default: left)
set -euo pipefail

WS="${ZMK_WORKSPACE:-$HOME/zmk-workspace}"
CFG="$(cd "$(dirname "$0")/config" && pwd)"
BOARD="${BOARD:-nice_nano_v2}"
SIDE="${1:-left}"
SHIELD="splitkb_aurora_corne_$SIDE"

# shellcheck disable=SC1091
source "$WS/.venv/bin/activate"
export ZEPHYR_TOOLCHAIN_VARIANT=zephyr
export ZEPHYR_SDK_INSTALL_DIR="$WS/zephyr-sdk-0.16.8"

cd "$WS"
west build -p -s zmk/app -d "build/$SHIELD" -b "$BOARD" \
  -- -DZMK_CONFIG="$CFG" -DSHIELD="$SHIELD"

cp "build/$SHIELD/zephyr/zmk.uf2" "$WS/$SHIELD.uf2"
echo "built: $WS/$SHIELD.uf2"
