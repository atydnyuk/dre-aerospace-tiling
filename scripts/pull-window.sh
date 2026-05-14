#!/bin/bash
# Pull any window from another workspace — swaps it with the currently focused window

# Capture current workspace and focused window before the picker opens
read -r CURRENT_WS CURRENT_WIN < <(
    aerospace list-windows --focused --format '%{workspace} %{window-id}' 2>/dev/null
)
[ -z "$CURRENT_WS" ] && exit 0

# Detect which slot CURRENT_WIN occupies: probe its right neighbor.
# If focus moves, CURRENT_WIN is in the left stack and the neighbor is the right 60% window.
CURRENT_SLOT="right"
RIGHT_WIN=""
aerospace focus right 2>/dev/null
PROBE=$(aerospace list-windows --focused --format '%{window-id}' 2>/dev/null)
aerospace focus --window-id "$CURRENT_WIN" 2>/dev/null
if [ -n "$PROBE" ] && [ "$PROBE" != "$CURRENT_WIN" ]; then
    CURRENT_SLOT="left"
    RIGHT_WIN="$PROBE"
fi

# Write tab-separated data for the inner picker: window-id TAB number  label
COUNTER=0
while IFS= read -r line; do
    COUNTER=$(( COUNTER + 1 ))
    printf '%s\t%d  %s\n' "$(cut -f1 <<< "$line")" "$COUNTER" "$(cut -f2- <<< "$line")"
done < <(
    aerospace list-windows --all \
        --format $'%{window-id}\t%{app-name}: %{window-title} [%{workspace}]' \
        2>/dev/null \
    | grep -v $'\t.*\['"${CURRENT_WS}"'\]$'
) > /tmp/aerospace-picker-data

if [ ! -s /tmp/aerospace-picker-data ]; then
    osascript -e 'display notification "No windows on other workspaces" with title "AeroSpace"'
    exit 0
fi

printf '%s' "$CURRENT_WS"   > /tmp/aerospace-picker-ws
printf '%s' "$CURRENT_WIN"  > /tmp/aerospace-picker-current-win
printf '%s' "$CURRENT_SLOT" > /tmp/aerospace-picker-slot
printf '%s' "$RIGHT_WIN"    > /tmp/aerospace-picker-right-win
aerospace list-windows --workspace "$CURRENT_WS" --count 2>/dev/null > /tmp/aerospace-picker-wincount
open -na Ghostty.app --args -e ~/.config/aerospace/scripts/pull-window-inner.sh
