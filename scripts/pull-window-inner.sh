#!/bin/bash
# Runs inside a Ghostty terminal — floats itself, shows fzf picker, swaps windows

WORKSPACE=$(cat /tmp/aerospace-picker-ws 2>/dev/null)
CURRENT_WIN=$(cat /tmp/aerospace-picker-current-win 2>/dev/null)
[ -z "$WORKSPACE" ] && exit 0
[ ! -s /tmp/aerospace-picker-data ] && exit 0

# Float this terminal window so it overlays the current layout
MY_WIN=$(aerospace list-windows --focused --format '%{window-id}' 2>/dev/null)
[ -n "$MY_WIN" ] && aerospace layout floating --window-id "$MY_WIN"

# fzf: col 1 is window-id (hidden), col 2+ is the numbered display label
# Typing a number filters to that item; --select-1 auto-accepts when only one match remains
CHOSEN=$(fzf \
    --select-1 \
    --exit-0 \
    --reverse \
    --border=rounded \
    --prompt="Pull to ws ${WORKSPACE} > " \
    --height=100% \
    --with-nth=2.. \
    < /tmp/aerospace-picker-data)

[ -z "$CHOSEN" ] && exit 0

WIN_ID=$(printf '%s' "$CHOSEN" | cut -f1)

# Extract the source workspace from the label suffix, e.g. "[4]" → "4"
SOURCE_WS=$(printf '%s' "$CHOSEN" | grep -oE '\[[^]]+\]$' | tr -d '[]')

# Focus CURRENT_WIN so WIN_ID lands adjacent to it in the tiling tree
[ -n "$CURRENT_WIN" ] && aerospace focus --window-id "$CURRENT_WIN"

# Pull WIN_ID in
aerospace move-node-to-workspace --window-id "$WIN_ID" "$WORKSPACE"

# Send CURRENT_WIN to the source workspace
if [ -n "$CURRENT_WIN" ] && [ -n "$SOURCE_WS" ]; then
    aerospace move-node-to-workspace --window-id "$CURRENT_WIN" "$SOURCE_WS"
fi

WIN_COUNT=$(cat /tmp/aerospace-picker-wincount 2>/dev/null)
CURRENT_SLOT=$(cat /tmp/aerospace-picker-slot 2>/dev/null)
RIGHT_WIN=$(cat /tmp/aerospace-picker-right-win 2>/dev/null)

if [ "$WIN_COUNT" = "3" ]; then
    # PIVOT is the window that takes the right 60% slot.
    # If CURRENT_WIN was on the right, WIN_ID inherits that slot.
    # If CURRENT_WIN was on the left, the original right window keeps its slot.
    if [ "$CURRENT_SLOT" = "right" ]; then
        PIVOT="$WIN_ID"
    else
        PIVOT="$RIGHT_WIN"
    fi

    # Floating windows are excluded from the tiling tree, so flatten+layout
    # operates on only the 3 tiled windows even though Ghostty is still open
    aerospace flatten-workspace-tree
    aerospace focus --window-id "$PIVOT"
    aerospace layout h_tiles
    aerospace move --boundaries-action stop right
    aerospace move --boundaries-action stop right
    aerospace focus left
    aerospace join-with left
    aerospace layout v_tiles
    aerospace focus --window-id "$PIVOT"
    aerospace resize width "+151"
fi

aerospace focus --window-id "$WIN_ID"
