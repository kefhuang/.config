#!/bin/bash
TARGET="$1"
CURRENT=$(aerospace list-workspaces --focused)

[ "$CURRENT" = "$TARGET" ] && exit 0

CURRENT_WINDOWS=$(aerospace list-windows --workspace "$CURRENT" --format '%{window-id}')
TARGET_WINDOWS=$(aerospace list-windows --workspace "$TARGET" --format '%{window-id}')

while IFS= read -r wid; do
    [ -n "$wid" ] && aerospace move-node-to-workspace "$TARGET" --window-id "$wid"
done <<< "$CURRENT_WINDOWS"

while IFS= read -r wid; do
    [ -n "$wid" ] && aerospace move-node-to-workspace "$CURRENT" --window-id "$wid"
done <<< "$TARGET_WINDOWS"

aerospace workspace "$TARGET"
