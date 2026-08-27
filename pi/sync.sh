#!/usr/bin/env bash
# Copy pi's config out of ~/.pi into this repo, stripping secrets and churn.
#
# pi is NOT symlinked like the other configs: it rewrites settings.json on every
# model load and version bump, and the file embeds a live apiKey. Run this after
# deliberately changing your pi setup.
#
# Files are built in a staging dir and only published once they are verified
# key-free, so a failed run can never leave a secret sitting in the repo.
set -euo pipefail

PI="${PI_HOME:-$HOME/.pi}"
DEST="${PI_DEST:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"
PLACEHOLDER="REPLACE_ME"

[[ -d "$PI" ]] || { echo "no $PI on this machine"; exit 1; }

STAGE="$(mktemp -d)"
trap 'rm -rf "$STAGE"' EXIT
mkdir -p "$STAGE/agent"

# settings.json: drop the api key, the changelog marker, and per-model runtime
# state (loaded/sizeBytes) that changes every time a model is loaded.
jq --arg k "$PLACEHOLDER" '
  del(.lastChangelogVersion)
  | (.localllm.servers[]?.apiKey) = $k
  | (.localllm.servers[]?.models[]?) |= del(.loaded, .sizeBytes)
' "$PI/agent/settings.json" > "$STAGE/agent/settings.json"

# models.json: same key, no runtime state to strip.
jq --arg k "$PLACEHOLDER" '
  (.providers[]?.apiKey) = $k
' "$PI/agent/models.json" > "$STAGE/agent/models.json"

# pi-ollama.json's "ollama" apiKey is the documented local placeholder, not a secret.
cp "$PI/agent/pi-ollama.json" "$STAGE/agent/pi-ollama.json"
cp "$PI/web-search.json"      "$STAGE/web-search.json"

# Catch a key sitting somewhere the jq filters above do not reach -- a new
# provider block, a renamed field. Staging means nothing is published if so.
if grep -rh '"apiKey"' "$STAGE" 2>/dev/null \
   | grep -qvE "\"apiKey\": ?\"(ollama|$PLACEHOLDER)\""; then
  echo "REFUSING: an unsanitized apiKey survived the filters:" >&2
  grep -rh '"apiKey"' "$STAGE" | grep -vE "\"apiKey\": ?\"(ollama|$PLACEHOLDER)\"" >&2
  echo "Nothing was written. Add the new path to the jq filters in $0." >&2
  exit 1
fi

mkdir -p "$DEST/agent"
cp "$STAGE/agent/"*.json "$DEST/agent/"
cp "$STAGE/web-search.json" "$DEST/web-search.json"

echo "synced to $DEST (no live keys)"
git -C "$DEST" status --short -- . 2>/dev/null || true
