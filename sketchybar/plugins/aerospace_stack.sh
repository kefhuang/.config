#!/usr/bin/env bash

set -euo pipefail

export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
export CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
export LC_CTYPE="${LC_CTYPE:-en_US.UTF-8}"

WORKSPACE_ORDER_STRING="${WORKSPACE_ORDER:-1 2 3 4 5 A C M S W}"
GET_MONITOR_WIDTH="$HOME/.config/aerospace/get-monitor-width"

CURRENT_BG="0xff244956"
CURRENT_BORDER="0xff3f7686"
CURRENT_TEXT="0xfff8fbfd"

OTHER_BG="0x44222222"
OTHER_BORDER="0x66444444"
OTHER_TEXT="0xffd5dee2"

friendly_name() {
    case "$1" in
        "Google Chrome") printf 'Chrome' ;;
        "Spark Desktop") printf 'Spark' ;;
        "Notion Calendar") printf 'Calendar' ;;
        *) printf '%s' "$1" ;;
    esac
}

trim_line() {
    printf '%s' "$1" | tr '\t' ' ' | tr '\n' ' ' | sed 's/[[:space:]][[:space:]]*/ /g; s/^ //; s/ $//'
}

shorten() {
    local value
    local limit

    value="$(trim_line "${1:-}")"
    limit="${2:-40}"

    if [ "$limit" -le 0 ]; then
        printf ''
    elif [ "${#value}" -le "$limit" ]; then
        printf '%s' "$value"
    elif [ "$limit" -le 3 ]; then
        printf '%s' "${value:0:$limit}"
    else
        printf '%s...' "${value:0:$((limit - 3))}"
    fi
}

first_chars() {
    local text
    local count

    text="$(trim_line "${1:-}")"
    count="${2:-2}"

    printf '%s' "$text" | cut -c "1-$count"
}

abbreviate_app() {
    local app
    local word
    local result=""

    app="$(trim_line "${1:-}")"
    [ -n "$app" ] || return 0

    if [[ "$app" == *" "* ]]; then
        for word in $app; do
            [ -n "$word" ] || continue
            result="${result}$(printf '%s' "$word" | cut -c '1')"
            [ "${#result}" -ge 2 ] && break
        done
    fi

    if [ -n "$result" ]; then
        printf '%s' "$result"
    else
        first_chars "$app" 2
    fi
}

join_apps() {
    local mode
    local app
    local token
    local joined=""

    mode="$1"
    shift

    for app in "$@"; do
        app="$(trim_line "$app")"
        [ -n "$app" ] || continue

        if [ "$mode" = "compact" ]; then
            token="$(abbreviate_app "$app")"
        else
            token="$app"
        fi

        if [ -n "$joined" ]; then
            joined="$joined / $token"
        else
            joined="$token"
        fi
    done

    printf '%s' "$joined"
}

list_apps_for_workspace() {
    local workspace
    local app
    local apps=()

    workspace="$1"

    while IFS= read -r app; do
        app="$(trim_line "$app")"
        [ -n "$app" ] && apps+=("$(friendly_name "$app")")
    done < <(aerospace list-windows --workspace "$workspace" --format '%{app-name}' 2>/dev/null)

    printf '%s\n' "${apps[@]:-}"
}

segment_cost() {
    local icon
    local label
    local cost

    icon="$1"
    label="$2"
    cost=$(( ${#icon} + 4 ))

    if [ -n "$label" ]; then
        cost=$(( cost + ${#label} ))
    fi

    printf '%s' "$cost"
}

lookup_display() {
    local key="$1"
    local entries="$2"
    local match="${entries##*${key}=}"

    if [ "$match" = "$entries" ]; then
        printf ''
        return
    fi

    printf '%s' "${match%%;*}"
}

has_workspace() {
    local target
    local ws

    target="$1"
    shift

    for ws in "$@"; do
        if [ "$ws" = "$target" ]; then
            return 0
        fi
    done

    return 1
}

hide_inactive_workspaces() {
    local visible_workspaces=("$@")
    local ws

    for ws in $WORKSPACE_ORDER_STRING; do
        if ! has_workspace "$ws" "${visible_workspaces[@]}"; then
            sketchybar --set "aerospace.ws.$ws" drawing=off label=""
        fi
    done
}

monitor_width_for_display() {
    local display_id="$1"
    local line mid mname width

    if ! command -v aerospace >/dev/null 2>&1; then
        printf '1440'
        return
    fi

    local monitor_name=""
    while IFS= read -r line; do
        mid="${line%% *}"
        mname="${line#* }"
        if [ "$mid" = "$display_id" ]; then
            monitor_name="$mname"
            break
        fi
    done < <(aerospace list-monitors --format '%{monitor-id} %{monitor-name}' 2>/dev/null)

    if [ -z "$monitor_name" ] || [ ! -x "$GET_MONITOR_WIDTH" ]; then
        printf '1440'
        return
    fi

    width="$("$GET_MONITOR_WIDTH" "$monitor_name" 2>/dev/null || true)"
    if [ -z "$width" ]; then
        printf '1440'
    else
        printf '%s' "$width"
    fi
}

available_chars_for_width() {
    local width="$1"
    local chars
    chars=$(( (width - 60) / 8 ))
    if [ "$chars" -lt 48 ]; then
        chars=48
    fi
    printf '%s' "$chars"
}

label_for_level() {
    local is_current
    local level
    local full_label
    local compact_label

    is_current="$1"
    level="$2"
    full_label="$3"
    compact_label="$4"

    if [ "$is_current" = "1" ]; then
        case "$level" in
            0|1|2) printf '%s' "$full_label" ;;
            3) printf '%s' "$compact_label" ;;
        esac
    else
        case "$level" in
            0) printf '%s' "$full_label" ;;
            1) printf '%s' "$compact_label" ;;
            2|3) printf '' ;;
        esac
    fi
}

refresh_workspaces() {
    local current_workspace
    local ws
    local current_known=0
    local current_index=-1
    local level
    local total
    local idx
    local label
    local full_label
    local compact_label
    local current_label
    local current_budget
    local item_name
    local workspace_names=()
    local workspace_current=()
    local workspace_full=()
    local workspace_compact=()
    local workspace_display=()
    local app_list=()
    local mon_id
    local ws_display_entries=""

    if ! command -v aerospace >/dev/null 2>&1; then
        hide_inactive_workspaces
        return
    fi

    while IFS= read -r mon_id; do
        [ -n "$mon_id" ] || continue
        while IFS= read -r ws; do
            ws="$(trim_line "$ws")"
            [ -n "$ws" ] || continue
            ws_display_entries="${ws_display_entries}${ws}=${mon_id};"
        done < <(aerospace list-workspaces --monitor "$mon_id" 2>/dev/null)
    done < <(aerospace list-monitors --format '%{monitor-id}' 2>/dev/null)

    current_workspace="$(aerospace list-workspaces --focused 2>/dev/null | head -n 1 || true)"
    if [ -z "$current_workspace" ]; then
        hide_inactive_workspaces
        return
    fi

    local visible_entries=";"
    local vws
    while IFS= read -r vws; do
        vws="$(trim_line "$vws")"
        [ -n "$vws" ] && visible_entries="${visible_entries}${vws};"
    done < <(aerospace list-workspaces --monitor all --visible --format '%{workspace}' 2>/dev/null)

    for ws in $WORKSPACE_ORDER_STRING; do
        [ "$ws" = "$current_workspace" ] && current_known=1

        app_list=()
        while IFS= read -r label; do
            [ -n "$label" ] && app_list+=("$label")
        done < <(list_apps_for_workspace "$ws")

        workspace_names+=("$ws")

        if [ "$ws" = "$current_workspace" ]; then
            workspace_current+=("1")
            current_index=$(( ${#workspace_names[@]} - 1 ))
        elif case "$visible_entries" in *";${ws};"*) true ;; *) false ;; esac; then
            workspace_current+=("1")
        else
            workspace_current+=("0")
        fi

        if [ "${#app_list[@]}" -gt 0 ]; then
            full_label="$(join_apps full "${app_list[@]}")"
            compact_label="$(join_apps compact "${app_list[@]}")"
        else
            full_label=""
            compact_label=""
        fi

        workspace_full+=("$full_label")
        workspace_compact+=("$compact_label")
        workspace_display+=("$(lookup_display "$ws" "$ws_display_entries")")
    done

    if [ "$current_known" -eq 0 ]; then
        workspace_names+=("$current_workspace")
        workspace_current+=("1")
        workspace_full+=("")
        workspace_compact+=("")
        workspace_display+=("$(lookup_display "$current_workspace" "$ws_display_entries")")
        current_index=$(( ${#workspace_names[@]} - 1 ))
    fi

    if [ "${#workspace_names[@]}" -eq 0 ] || [ "$current_index" -lt 0 ]; then
        hide_inactive_workspaces
        return
    fi

    local unique_displays=""
    local disp
    for idx in "${!workspace_names[@]}"; do
        disp="${workspace_display[$idx]}"
        [ -z "$disp" ] && continue
        case ";${unique_displays};" in
            *";${disp};"*) ;;
            *) unique_displays="${unique_displays}${disp};" ;;
        esac
    done

    local display_level_entries=""
    for disp in $(printf '%s' "$unique_displays" | tr ';' ' '); do
        [ -z "$disp" ] && continue
        local disp_width disp_avail disp_level=3
        disp_width="$(monitor_width_for_display "$disp")"
        disp_avail="$(available_chars_for_width "$disp_width")"

        for level in 0 1 2 3; do
            total=0
            for idx in "${!workspace_names[@]}"; do
                [ "${workspace_display[$idx]}" = "$disp" ] || continue
                label="$(label_for_level "${workspace_current[$idx]}" "$level" "${workspace_full[$idx]}" "${workspace_compact[$idx]}")"
                total=$(( total + $(segment_cost "${workspace_names[$idx]}" "$label") ))
            done
            if [ "$total" -le "$disp_avail" ]; then
                disp_level="$level"
                break
            fi
        done

        display_level_entries="${display_level_entries}${disp}=${disp_level};"
    done

    local current_disp="${workspace_display[$current_index]}"
    local current_disp_level
    current_disp_level="$(lookup_display "$current_disp" "$display_level_entries")"
    [ -z "$current_disp_level" ] && current_disp_level=3

    current_label="$(label_for_level "1" "$current_disp_level" "${workspace_full[$current_index]}" "${workspace_compact[$current_index]}")"

    if [ "$current_disp_level" -eq 3 ] && [ -n "$current_disp" ]; then
        local cur_disp_width cur_disp_avail
        cur_disp_width="$(monitor_width_for_display "$current_disp")"
        cur_disp_avail="$(available_chars_for_width "$cur_disp_width")"
        total=0
        for idx in "${!workspace_names[@]}"; do
            [ "${workspace_display[$idx]}" = "$current_disp" ] || continue
            [ "$idx" -eq "$current_index" ] && continue
            total=$(( total + $(segment_cost "${workspace_names[$idx]}" "") ))
        done
        current_budget=$(( cur_disp_avail - total - $(segment_cost "${workspace_names[$current_index]}" "") ))
        if [ "$current_budget" -lt 0 ]; then
            current_budget=0
        fi
        current_label="$(shorten "$current_label" "$current_budget")"
    fi

    for idx in "${!workspace_names[@]}"; do
        ws="${workspace_names[$idx]}"
        item_name="aerospace.ws.$ws"
        local ws_disp="${workspace_display[$idx]}"

        if [ -z "$ws_disp" ]; then
            sketchybar --set "$item_name" drawing=off label=""
            continue
        fi

        local bg_color border_color text_color
        if [ "${workspace_current[$idx]}" = "1" ]; then
            bg_color="$CURRENT_BG"
            border_color="$CURRENT_BORDER"
            text_color="$CURRENT_TEXT"
        else
            bg_color="$OTHER_BG"
            border_color="$OTHER_BORDER"
            text_color="$OTHER_TEXT"
        fi

        if [ "$idx" -eq "$current_index" ]; then
            label="$current_label"
        else
            local ws_level
            ws_level="$(lookup_display "$ws_disp" "$display_level_entries")"
            [ -z "$ws_level" ] && ws_level=3
            label="$(label_for_level "${workspace_current[$idx]}" "$ws_level" "${workspace_full[$idx]}" "${workspace_compact[$idx]}")"
        fi

        if [ -z "$label" ]; then
            sketchybar --set "$item_name" display="$ws_disp" \
                                          drawing=on          \
                                          icon="$ws"         \
                                          label=""            \
                                          icon.padding_left=8 \
                                          icon.padding_right=8 \
                                          label.padding_left=0 \
                                          label.padding_right=0 \
                                          icon.color="$text_color" \
                                          label.color="$text_color" \
                                          background.color="$bg_color" \
                                          background.border_color="$border_color"
        else
            sketchybar --set "$item_name" display="$ws_disp" \
                                          drawing=on          \
                                          icon="$ws"         \
                                          label="$label"     \
                                          icon.padding_left=10 \
                                          icon.padding_right=6 \
                                          label.padding_left=0 \
                                          label.padding_right=10 \
                                          icon.color="$text_color" \
                                          label.color="$text_color" \
                                          background.color="$bg_color" \
                                          background.border_color="$border_color"
        fi
    done

    hide_inactive_workspaces "${workspace_names[@]}"
}

refresh_workspaces
