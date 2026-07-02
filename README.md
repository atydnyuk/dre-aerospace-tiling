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

## ErgoDox EZ (Dvorak) mode

The ErgoDox EZ's Dvorak layer lives entirely in its firmware — macOS's own
input source stays on QWERTY, and `key-mapping.preset` in
[.aerospace.toml](.aerospace.toml) is left at `'qwerty'` globally. A second
top-level binding mode, `ergodox`, holds Dvorak-typed equivalents of the
`main` bindings, and `scripts/aerospace-kb-watch.sh` switches between `main`
and `ergodox` automatically based on whether the ErgoDox is plugged in.

vim-style focus/move keys are hand-swapped to Dvorak's left-hand home-row
vowels rather than position-matched to the physical h/j/k/l keys:

| QWERTY (`main`) | Dvorak (`ergodox`) | Action |
|---|---|---|
| `alt-h` | `alt-a` | Focus left |
| `alt-j` | `alt-o` | Focus down |
| `alt-k` | `alt-e` | Focus up |
| `alt-l` | `alt-u` | Focus right |
| `alt-shift-h/j/k/l` | `alt-shift-a/o/e/u` | Move window left/down/up/right |

Because `a`/`o`/`e`/`u` are also workspace letters (A/O/E/U) in `main`,
those four workspaces have no direct `alt+letter` jump in `ergodox` mode —
reach them via `alt-tab` or by moving windows into them. Everything else
(digits, other workspace letters, layout/resize, `alt-0` tools mode,
`alt-shift-;` service mode) works the same on both keyboards.

### Auto-switching

`install.sh` installs a LaunchAgent
(`~/Library/LaunchAgents/com.dre.aerospace-kb-watch.plist`) that polls every
5 seconds for the ErgoDox on the USB bus (`ioreg`, matched by name and by
ZSA's vendor ID `0x3297`) and runs `aerospace mode ergodox` / `aerospace
mode main` on a state change, debounced via `/tmp/aerospace-kb-mode`. Logs
go to `/tmp/aerospace-kb-watch.log`.

To check on it or manage it manually:

```bash
launchctl list | grep aerospace-kb-watch
cat /tmp/aerospace-kb-mode          # last mode the watcher set
launchctl unload ~/Library/LaunchAgents/com.dre.aerospace-kb-watch.plist
```

## Features

### 3-window layout (`alt-0 → 3`)

Arranges three windows into a 40/60 split: the focused window takes the right 60%, and the other two stack vertically on the left 40%.

### Window picker (`alt-0 → p`)

Opens a floating fzf picker listing all windows on other workspaces. Select with arrow keys + enter, or type a number to jump directly to that item. ESC cancels.

On selection, the chosen window is pulled into the current workspace and the previously focused window is sent to the source workspace (swap). In a 3-window layout, the layout is re-applied and the swapped window inherits the slot of the window it replaced.
