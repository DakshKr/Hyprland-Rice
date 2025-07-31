#!/usr/bin/env bash

# ... (header comments) ...

notify="notify-send"
SESSION_TYPE="$XDG_SESSION_TYPE"
ENABLED_COLOR="#FFEE8C"
DISABLED_COLOR="#d35f5e"

# NEW: File to store the current DND status managed by this script
DND_STATE_FILE="/tmp/swaync_dnd_status.flag"
# Initial state: Assume DND is OFF if the file doesn't exist
# This is important for the first run or after a reboot.
# We'll write 'false' to the file if it's empty, meaning DND is initially off.
if [ ! -f "$DND_STATE_FILE" ] || [ -z "$(cat "$DND_STATE_FILE" 2>/dev/null)" ]; then
    echo "false" > "$DND_STATE_FILE"
fi

# --- Function to toggle SwayNC's Do Not Disturb state ---
toggle_dnd() {
    local current_state=$(cat "$DND_STATE_FILE" 2>/dev/null)

    if [ "$current_state" == "true" ]; then
        # DND is currently ON (according to our flag), so turn it OFF
        swaync-client --toggle-dnd off
        echo "false" > "$DND_STATE_FILE" # Update our flag
        notify-send "Notifications" "🔔 Active" -u low
    else
        swaync-client --toggle-dnd on
        echo "true" > "$DND_STATE_FILE" # Update our flag

            notify-send "Notifications" "🔕 Do Not Disturb" -u critical
        # DND is currently OFF (according to our flag), so turn it ON

    fi
}

# --- Function to open/toggle SwayNC notification center ---
toggle_swaync_center() {
    swaync-client -t
}

# --- Function to get current DND status icon and color for Waybar ---
get_status() {
    # Read status from our own managed flag file
    local is_dnd_enabled=$(cat "$DND_STATE_FILE" 2>/dev/null)

    local icon=""
    local color=""

    if [ "$is_dnd_enabled" == "true" ]; then
        icon="󰍷" # Icon for DND enabled (notifications paused)
        color=$DISABLED_COLOR
    else
        icon="󰍶" # Icon for DND disabled (notifications active)
        color=$ENABLED_COLOR
    fi

    if [[ "$SESSION_TYPE" == "wayland" ]]; then
        echo "<span color=\"$color\">$icon</span>"
    elif [[ "$SESSION_TYPE" == "x11" ]]; then
        echo "%{F$color}$icon%{F-}"
    fi
}

# --- Main logic based on arguments ---
case "$1" in
    --status)
        get_status
        ;;
    --left-click)
        toggle_swaync_center
        ;;
    --right-click)
        toggle_dnd
        ;;
    --enabled-color)
        ENABLED_COLOR="$2"
        shift
        ;;
    --disabled-color)
        DISABLED_COLOR="$2"
        shift
        ;;
    *)
        echo "Usage: $0 --status | --left-click | --right-click [--enabled-color <color>] [--disabled-color <color>]" >&2
        exit 1
        ;;
esac