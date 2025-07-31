#!/usr/bin/env bash

# A more robust, toggleable Rofi-based powermenu using a PID file.

PID_FILE="/tmp/rofi_powermenu.pid"

# --- Toggling Logic ---
# Check if the PID file exists and if the process it points to is still running.
if [ -f "$PID_FILE" ] && ps -p "$(cat "$PID_FILE")" > /dev/null; then
    # If so, kill that specific Rofi instance. This is the "toggle off" action.
    kill "$(cat "$PID_FILE")"
    exit 0
fi

# Define options with Nerd Font icons
lock=" Lock"
logout=" Logout"
suspend=" Suspend"
reboot=" Reboot"
shutdown=" Shutdown"

# Get user's choice, writing the Rofi PID to our file for toggling.
chosen=$(echo -e "$lock\n$logout\n$suspend\n$reboot\n$shutdown" | rofi \
    -dmenu \
    -i \
    -p "Power" \
    -theme ~/.config/rofi/powermenu.rasi \
    -pid "$PID_FILE")

case "$chosen" in
    "$lock")
        hyprlock
        ;;
    "$logout")
        hyprctl dispatch exit
        ;;
    "$suspend")
        systemctl suspend
        ;;
    "$reboot")
        systemctl reboot
        ;;
    "$shutdown")
        systemctl poweroff # 'poweroff' is often preferred for immediate shutdown
        ;;
esac


# --- Cleanup ---
# Ensure the PID file is removed when the script exits, so it's ready for the next launch.
rm -f "$PID_FILE"
