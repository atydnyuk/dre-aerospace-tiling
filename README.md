# AeroSpace Config

Personal [AeroSpace](https://nikitabobko.github.io/AeroSpace) config for macOS with keyboard-driven window management.

## Install

```bash
git clone https://github.com/atydnyuk/dre-aerospace-tiling.git ~/dev/aerospace-config
cd ~/dev/aerospace-config
bash install.sh
aerospace reload-config
```

The install script symlinks `~/.aerospace.toml` and `~/.config/aerospace/scripts` into the repo. Any existing files are backed up with a `.bak` suffix.

## Dependencies

- [AeroSpace](https://github.com/nikitabobko/AeroSpace) — tiling window manager
- [fzf](https://github.com/junegunn/fzf) — fuzzy finder for the window picker (`brew install fzf`)
- [Ghostty](https://ghostty.org) — terminal used to host the picker UI

## Keybindings

Standard AeroSpace bindings are unchanged:

| Key | Action |
|-----|--------|
| `alt-h/j/k/l` | Focus window left/down/up/right |
| `alt-shift-h/j/k/l` | Move window left/down/up/right |
| `alt-1…9, a…z` | Switch to workspace |
| `alt-shift-1…9, a…z` | Move window to workspace |
| `alt-tab` | Toggle last workspace |
| `alt-shift-tab` | Move workspace to next monitor |
| `alt-/` | Cycle tile layout (horizontal/vertical) |
| `alt-,` | Cycle accordion layout |
| `alt--` / `alt-=` | Resize window -/+ 50px |

### Tools mode (`alt-0`, exit with `esc`)

| Key | Action |
|-----|--------|
| `3` | Apply 3-window layout |
| `p` | Open window picker |

## Features

### 3-window layout (`alt-0 → 3`)

Arranges three windows into a 40/60 split: the focused window takes the right 60%, and the other two stack vertically on the left 40%.

### Window picker (`alt-0 → p`)

Opens a floating fzf picker listing all windows on other workspaces. Select with arrow keys + enter, or type a number to jump directly to that item. ESC cancels.

On selection, the chosen window is pulled into the current workspace and the previously focused window is sent to the source workspace (swap). In a 3-window layout, the layout is re-applied and the swapped window inherits the slot of the window it replaced.
