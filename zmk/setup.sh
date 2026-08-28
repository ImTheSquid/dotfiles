#!/usr/bin/env bash
# One-time ZMK toolchain setup. Idempotent; safe to re-run.
set -euo pipefail

WS="${ZMK_WORKSPACE:-$HOME/zmk-workspace}"
CFG="$(cd "$(dirname "$0")/config" && pwd)"
SDK_VER=0.16.8
SDK_DIR="$WS/zephyr-sdk-$SDK_VER"

brew list --formula gperf ccache dtc libmagic wget cmake ninja >/dev/null

mkdir -p "$WS"
# west resolves symlinks and would plant .west next to the real config dir, so
# the manifest is copied rather than linked. The keymap/conf stay in the repo
# and reach the build via -DZMK_CONFIG in build.sh.
mkdir -p "$WS/config"
cp "$CFG/west.yml" "$WS/config/west.yml"

[ -d "$WS/.venv" ] || python3 -m venv "$WS/.venv"
# shellcheck disable=SC1091
source "$WS/.venv/bin/activate"
pip install -q --upgrade pip west

cd "$WS"
[ -d .west ] || west init -l config
west update
west zephyr-export
pip install -q -r zephyr/scripts/requirements-base.txt

if [ ! -d "$SDK_DIR" ]; then
  ARCH="$(uname -m)"; [ "$ARCH" = arm64 ] && ARCH=aarch64
  TARBALL="zephyr-sdk-${SDK_VER}_macos-${ARCH}_minimal.tar.xz"
  wget -q --show-progress -O "$WS/$TARBALL" \
    "https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v${SDK_VER}/${TARBALL}"
  tar xf "$WS/$TARBALL" -C "$WS"
  rm "$WS/$TARBALL"
  "$SDK_DIR/setup.sh" -t arm-zephyr-eabi -c
fi

echo "ZMK workspace ready at $WS"
