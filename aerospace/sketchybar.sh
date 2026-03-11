#!/usr/bin/env bash

set -euo pipefail

export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"

SKETCHYBAR_BIN="/opt/homebrew/bin/sketchybar"
CONFIG_PATH="${CONFIG_PATH:-$HOME/.config/aerospace/aerospace.toml}"
BAR_GAP="${BAR_GAP:-48}"
DEFAULT_GAP="${DEFAULT_GAP:-8}"

bar_is_ready() {
    [ -x "$SKETCHYBAR_BIN" ] || return 1
    "$SKETCHYBAR_BIN" --query bar >/dev/null 2>&1
}

start_bar() {
    local attempt

    [ -x "$SKETCHYBAR_BIN" ] || return 1

    if bar_is_ready; then
        return 0
    fi

    "$SKETCHYBAR_BIN" >/dev/null 2>&1 || true

    for attempt in 1 2 3 4 5 6 7 8 9 10; do
        if bar_is_ready; then
            return 0
        fi
        sleep 0.2
    done

    return 1
}

current_bottom_gap() {
    awk -F= '
        /^[[:space:]]*outer\.bottom[[:space:]]*=/ {
            gsub(/[[:space:]]/, "", $2)
            print $2
            exit
        }
    ' "$CONFIG_PATH"
}

set_bottom_gap() {
    local desired_gap
    local current_gap

    desired_gap="$1"
    current_gap="$(current_bottom_gap)"

    [ -n "$current_gap" ] || return 1
    [ "$current_gap" = "$desired_gap" ] && return 0

    CONFIG_PATH="$CONFIG_PATH" DESIRED_GAP="$desired_gap" perl -0pi -e \
        's/^(\s*outer\.bottom\s*=\s*)\d+/${1}$ENV{DESIRED_GAP}/m' \
        "$CONFIG_PATH"

    aerospace reload-config >/dev/null 2>&1 || true
}

sync_gap() {
    if start_bar; then
        set_bottom_gap "$BAR_GAP"
    else
        set_bottom_gap "$DEFAULT_GAP"
    fi
}

trigger_bar() {
    if bar_is_ready; then
        "$SKETCHYBAR_BIN" --trigger aerospace_focus_change >/dev/null 2>&1 || true
    fi
}

case "${1:-start}" in
    start)
        sync_gap
        ;;
    trigger)
        trigger_bar
        ;;
    *)
        printf 'Usage: %s [start|trigger]\n' "$0" >&2
        exit 1
        ;;
esac
