#!/usr/bin/env bash
# Symlink every config in this repo to where its app expects it.
# Idempotent: re-running only replaces links, never real files.
set -euo pipefail

DOTS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GHOSTTY_DIR="$HOME/Library/Application Support/com.mitchellh.ghostty"

# Flat src/dest pairs. Destinations may contain spaces, so never word-split these.
LINKS=(
  "yabai/.yabairc"                "$HOME/.yabairc"
  "sketchybar"                    "$HOME/.config/sketchybar"
  "karabiner"                     "$HOME/.config/karabiner"
  "nvim"                          "$HOME/.config/nvim"
  "ghostty/config"                "$GHOSTTY_DIR/config"
  "zsh/.zshrc"                    "$HOME/.zshrc"
  "zsh/.zprofile"                 "$HOME/.zprofile"
  "zsh/.zshenv"                   "$HOME/.zshenv"
  "git/.gitconfig"                "$HOME/.gitconfig"
  "git/.gitignore"                "$HOME/.gitignore"
  "git/ignore"                    "$HOME/.config/git/ignore"
  "starship/starship.toml"        "$HOME/.config/starship.toml"
  "zed/settings.json"             "$HOME/.config/zed/settings.json"
  "scripts/toggle_yabai_focus.sh" "$HOME/toggle_yabai_focus.sh"
)

link() {
  local src="$DOTS/$1" dest="$2"

  [[ -e "$src" ]] || { echo "  skip   $1 (missing in repo)"; return; }
  mkdir -p "$(dirname "$dest")"

  # Already pointing at the right place.
  if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then
    echo "  ok     $2"
    return
  fi

  # Back up anything real that would be clobbered.
  if [[ -e "$dest" && ! -L "$dest" ]]; then
    mv "$dest" "$dest.bak.$(date +%Y%m%d%H%M%S)"
    echo "  backup $2 -> $(basename "$dest").bak.*"
  else
    rm -f "$dest"
  fi

  ln -s "$src" "$dest"
  echo "  link   $2"
}

echo "Linking dotfiles from $DOTS"
for ((i = 0; i < ${#LINKS[@]}; i += 2)); do
  link "${LINKS[i]}" "${LINKS[i + 1]}"
done

chmod +x "$DOTS/yabai/.yabairc" "$DOTS/scripts/toggle_yabai_focus.sh"

# ~/.sketchybarrc is what the sketchybar launch agent reads.
ln -sfn "$HOME/.config/sketchybar/sketchybarrc" "$HOME/.sketchybarrc"
echo "  link   $HOME/.sketchybarrc"

# nvim keeps plugins, shada, swap and its luac cache in these. Running `sudo nvim`
# once creates them owned by root, and every later run then fails to write them.
NVIM_DIRS=(
  "$HOME/.local/share/nvim"
  "$HOME/.local/state/nvim"
  "$HOME/.cache/nvim"
)
STOLEN=()
for dir in "${NVIM_DIRS[@]}"; do
  mkdir -p "$dir" 2>/dev/null || true
  [[ -O "$dir" ]] || STOLEN+=("$dir")
done
if ((${#STOLEN[@]})); then
  echo "  WARN   nvim dirs not owned by $USER: ${STOLEN[*]}"
  echo "         fix with: sudo chown -R $USER:staff ${STOLEN[*]}"
fi

if [[ ! -f "$HOME/.zsh_secrets" ]]; then
  cat > "$HOME/.zsh_secrets" <<'EOF'
#!/usr/bin/env zsh
# Machine-local secrets. NOT in the dotfiles repo. Never commit this file.
EOF
  chmod 600 "$HOME/.zsh_secrets"
  echo "  create $HOME/.zsh_secrets (add tokens here)"
fi

cat <<'EOF'

Done. Remaining manual steps:
  brew install yabai sketchybar
  brew install --cask ghostty karabiner-elements
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  git clone https://github.com/zsh-users/zsh-autosuggestions     ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
  git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
  yabai --start-service && brew services start sketchybar

yabai's scripting addition needs passwordless sudo:
  https://github.com/koekeishiya/yabai/wiki/Installing-yabai-(latest-release)#configure-scripting-addition
EOF
