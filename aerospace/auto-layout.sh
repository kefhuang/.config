#!/bin/bash
THRESHOLD=1920
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

MONITOR_NAME=$(aerospace list-monitors --focused --format '%{monitor-name}')
WIDTH=$("$SCRIPT_DIR/get-monitor-width" "$MONITOR_NAME" 2>/dev/null)

[ -z "$WIDTH" ] && exit 1

if [ "$WIDTH" -lt "$THRESHOLD" ]; then
    LAYOUT="accordion"
else
    LAYOUT="tiles"
fi

aerospace list-workspaces --monitor focused | while read -r ws; do
    WID=$(aerospace list-windows --workspace "$ws" --format '%{window-id}' | head -1)
    [ -n "$WID" ] && aerospace layout --window-id "$WID" $LAYOUT 2>/dev/null || true
done
