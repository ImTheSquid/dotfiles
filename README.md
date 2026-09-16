# dotfiles

macOS config. Everything lives here; `install.sh` symlinks it into place.

```sh
git clone https://github.com/ImTheSquid/dotfiles ~/dotfiles
~/dotfiles/install.sh
```

## Contents

| Path | Links to | Notes |
| --- | --- | --- |
| `aerospace/aerospace.toml` | `~/.aerospace.toml` | Tiling WM, and all window-management keybinds. |
| `sketchybar/` | `~/.config/sketchybar` | Status bar; driven by AeroSpace callbacks. |
| `sketchybar/spaces.local.sh` | **not committed** | Optional per-machine workspace names. |
| `karabiner/` | `~/.config/karabiner` | caps→esc, the ZMK device remap, volume keys. |
| `nvim/` | `~/.config/nvim` | |
| `ghostty/config` | `~/Library/Application Support/com.mitchellh.ghostty/config` | Terminal. |
| `zsh/` | `~/.zshrc`, `~/.zprofile`, `~/.zshenv` | oh-my-zsh, theme `gnzh`. |
| `git/` | `~/.gitconfig`, `~/.gitignore`, `~/.config/git/ignore` | Commits are GPG-signed. |
| `starship/starship.toml` | `~/.config/starship.toml` | |
| `zed/settings.json` | `~/.config/zed/settings.json` | |
| `firefox/userChrome.css` | manual | Drop into the profile's `chrome/`. |
| `pi/` | **not linked** | pi agent config. See below. |
| `yabai/.yabairc` | **not linked** | Previous WM. Kept for rollback only. |

## sketchybar

Workspace names default to those in `sketchybarrc`. To change them on one
machine, create `~/.config/sketchybar/spaces.local.sh` (gitignored) and reassign
the array — one chip per entry:

```sh
SPACE_NAMES=("Web" "Code" "Chat" "4" "5")
```

`SPACE_NAMES` is cosmetic only. Which workspaces *exist* is set by
`persistent-workspaces` in `aerospace/aerospace.toml`, so the two are separate
sources of truth and want keeping in sync — a short `SPACE_NAMES` leaves the
higher workspaces reachable by keybind with no chip on the bar.

AeroSpace workspace names must stay numeric. The chip named `space.3` addresses
workspace `3` in its click script, and the driver plugin compares that number
against `aerospace list-workspaces --focused` to decide what to highlight.

One hidden `spaces_driver` item refreshes every chip in a single pass, on the
`aerospace_workspace_change` event plus a 2s timer. The timer is there because
AeroSpace has no window-closed callback — opens, workspace switches and
window moves all push the event, so only closing a window waits for a tick.
The braille dots count every window AeroSpace knows about, including floating
and minimized ones; yabai used to filter those out.

## pi

`~/.pi` is 562M of `node_modules`, model caches, sessions and logs; only four
small JSON files are worth keeping. They are **copied, not symlinked**, because
pi rewrites `settings.json` on every model load and embeds a live API key in it.

```sh
pi/sync.sh          # ~/.pi -> repo, stripping keys and volatile fields
```

The sync stages files, verifies no live `apiKey` survived, and only then writes
into the repo — a failed run publishes nothing. Every `apiKey` in `pi/` reads
`REPLACE_ME`; substitute the real oMLX key by hand when restoring. `auth.json`
is gitignored and must stay that way.

Restoring on a new machine means copying `pi/agent/*.json` and
`pi/web-search.json` back into `~/.pi`, then fixing up the key — pi repopulates
the model catalog itself.

## Secrets

Nothing secret is committed. `zsh/.zshrc` sources `~/.zsh_secrets` if present —
put tokens there. `~/.npmrc` holds a registry token and is deliberately not
tracked.

## Gotchas

- **Karabiner and directories.** Karabiner-Elements saves `karabiner.json` with
  an atomic rename, which replaces a file symlink with a real file. The whole
  directory is linked instead so edits land in the repo.
- **Ghostty path.** On macOS Ghostty reads Application Support, not `~/.config`.
- **macOS owns some of these chords by default.** "Switch to Desktop 1/2/3"
  (ctrl+1/2/3) and "Move left/right a space" (ctrl+←/→) are enabled system
  shortcuts and win against AeroSpace's. Karabiner used to mask this by
  intercepting below symbolic-hotkey dispatch; native AeroSpace bindings do not.
  Uncheck them in System Settings → Keyboard → Keyboard Shortcuts → Mission
  Control.
- **AeroSpace lives in one macOS space.** Its workspaces are virtual, not
  Mission Control desktops. Leave extra desktops around and the workspace
  keybinds behave unpredictably.
- **Mouse move and resize are undocumented but built in.** Drag a tiled
  window's edge to resize it; drag one tiled window onto another to swap them.
  There is no `fn`-style modifier gate like yabai had, so use the normal grab
  affordances. `defaults write -g NSWindowShouldDragOnGesture -bool true` adds
  ctrl+cmd drag from anywhere on a window.
- **`aerospace.toml` auto-reloads.** A syntax error can leave you with no
  window-management keys at all, so keep a terminal open on a floating window
  while editing it.
- **Native fullscreen gets its own macOS Space; AeroSpace's does not.**
  `cmd-enter` (`fullscreen --no-outer-gaps`) fills the monitor inside the
  current workspace, so every binding keeps working — use it. `cmd-shift-enter`
  (`macos-native-fullscreen`) hands the window a separate Space, and while
  you're in it `ctrl+N` only escapes if workspace N has a window to raise;
  an empty workspace is a dead end. `cmd-shift-enter` always gets you back out,
  because it acts on the focused window without switching Spaces.

  Apps that fullscreen themselves (a video player, YouTube's fullscreen button)
  use the native kind, and no config here can stop them. In a browser, prefer
  the site's own maximize (YouTube's `t` for theater mode) plus `cmd-enter`.
  Firefox can be made to stop using native fullscreen entirely, via
  `full-screen-api.macos-native-full-screen = false` in `about:config`;
  Chromium-based browsers have no equivalent pref.

## Rolling back to yabai

`yabai/.yabairc` is still here and `brew`'s yabai is still installed.

```sh
pkill -x AeroSpace
git revert <commit>                                  # restores karabiner + sketchybar
chmod +x ~/dotfiles/yabai/.yabairc                   # yabai execs it; without
ln -sfn ~/dotfiles/yabai/.yabairc ~/.yabairc         # +x it acts unconfigured
yabai --start-service
brew services restart sketchybar
```

yabai was transferred from `koekeishiya/yabai` to `asmvik/yabai`, so its launch
agent is `com.asmvik.yabai` and `--start-service` / `--stop-service` manage that
one. A stale `com.koekeishiya.yabai.plist` from before the transfer may also be
loaded; it holds no PID and can be deleted.

This path depends on SIP and `/etc/sudoers.d/yabai` staying as they are:
yabai's scripting addition needs both. Closing it out, once AeroSpace has
earned its keep, means `brew uninstall yabai`, `sudo rm /etc/sudoers.d/yabai`,
deleting both launch agent plists, and `csrutil enable` from Recovery — after
which there is no going back.
