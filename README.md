# dotfiles

macOS config. Everything lives here; `install.sh` symlinks it into place.

```sh
git clone https://github.com/ImTheSquid/dotfiles ~/dotfiles
~/dotfiles/install.sh
```

## Contents

| Path | Links to | Notes |
| --- | --- | --- |
| `yabai/.yabairc` | `~/.yabairc` | Tiling WM. Must stay executable. |
| `sketchybar/` | `~/.config/sketchybar` | Status bar; driven by yabai signals. |
| `karabiner/` | `~/.config/karabiner` | All window-management keybinds (replaced skhd). |
| `nvim/` | `~/.config/nvim` | |
| `ghostty/config` | `~/Library/Application Support/com.mitchellh.ghostty/config` | Terminal. |
| `zsh/` | `~/.zshrc`, `~/.zprofile`, `~/.zshenv` | oh-my-zsh, theme `gnzh`. |
| `git/` | `~/.gitconfig`, `~/.gitignore`, `~/.config/git/ignore` | Commits are GPG-signed. |
| `starship/starship.toml` | `~/.config/starship.toml` | |
| `zed/settings.json` | `~/.config/zed/settings.json` | |
| `scripts/toggle_yabai_focus.sh` | `~/toggle_yabai_focus.sh` | Karabiner calls this by absolute path. |
| `firefox/userChrome.css` | manual | Drop into the profile's `chrome/`. |

## Secrets

Nothing secret is committed. `zsh/.zshrc` sources `~/.zsh_secrets` if present —
put tokens there. `~/.npmrc` holds a registry token and is deliberately not
tracked.

## Gotchas

- **Karabiner and directories.** Karabiner-Elements saves `karabiner.json` with
  an atomic rename, which replaces a file symlink with a real file. The whole
  directory is linked instead so edits land in the repo.
- **Ghostty path.** On macOS Ghostty reads Application Support, not `~/.config`.
- **`~/.yabairc` needs the exec bit.** yabai runs it as a program; without `+x`
  it starts with no config at all and silently behaves like a fresh install.
