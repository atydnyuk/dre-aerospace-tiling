#!/bin/bash
# Layout: focused window → right 60%; other two → left 40% stacked top/bottom

read -r WORKSPACE FOCUSED_ID < <(
    aerospace list-windows --focused --format '%{workspace} %{window-id}'
)
[ -z "$WORKSPACE" ] && exit 0

WIN_COUNT=$(aerospace list-windows --workspace "$WORKSPACE" --count)
[ "$WIN_COUNT" -lt 3 ] && exit 0

aerospace flatten-workspace-tree
aerospace focus --window-id "$FOCUSED_ID"
aerospace layout h_tiles
aerospace move --boundaries-action stop right
aerospace move --boundaries-action stop right
aerospace focus left
aerospace join-with left
aerospace layout v_tiles
aerospace focus --window-id "$FOCUSED_ID"
# 151px ≈ 10% of 1512px logical width (Built-in Retina Display); adjust if using external monitors
aerospace resize width "+151"
