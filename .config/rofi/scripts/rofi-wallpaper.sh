#!/bin/bash

# ================================================================= #
#       A Toggleable Rofi Script for Wallpaper Selection            #
# ================================================================= #

# --- CONFIGURATION ---
# 1. Set the directory where your wallpapers are stored.
WALLPAPER_DIR="$HOME/Pictures/Wallpapers"

# 2. Set the path to your Rofi theme file.
THEME="$HOME/.config/rofi/themes/wallpaper-preview.rasi"

# 3. Define a unique PID file to enable toggling. (NEW)
PID_FILE="/tmp/rofi_wallpaper.pid"
# --- END OF CONFIGURATION ---

# --- TOGGLING LOGIC (NEW) ---
# If the script is run while an instance is already open, kill the old one.
if [ -f "$PID_FILE" ] && ps -p "$(cat "$PID_FILE")" > /dev/null; then
    kill "$(cat "$PID_FILE")"
    exit 0
fi

# Check if the wallpaper directory actually exists.
if [ ! -d "$WALLPAPER_DIR" ]; then
  rofi -e "Wallpaper directory not found: $WALLPAPER_DIR"
  exit 1
fi

# Function to generate the list of wallpapers for Rofi.
generate_wallpaper_list() {
    cd "$WALLPAPER_DIR"
    # Use 'ls -v' to list files in a natural sort order (1, 2, ..., 9, 10).
    ls -v *.{jpg,jpeg,png,gif,webp} 2>/dev/null | while read -r wallpaper; do
        echo -en "$wallpaper\0icon\x1f$WALLPAPER_DIR/$wallpaper\n"
    done
}

# --- MAIN EXECUTION ---
# We've added the '-pid' flag to make Rofi write its process ID to our file.
SELECTED=$(generate_wallpaper_list | rofi \
    -dmenu \
    -pid "$PID_FILE" \
    -no-sort \
    -show-icons \
    -i \
    -p "Wallpaper" \
    -theme "$THEME")

# If the user chose a wallpaper...
if [ -n "$SELECTED" ]; then
    # ...set the chosen wallpaper using swww.
    swww img "$WALLPAPER_DIR/$SELECTED" \
        --transition-type "center" \
        --transition-fps 90 \
        --transition-duration 0.5
fi

# --- CLEANUP (NEW) ---
# Always remove the PID file when the script finishes.
rm -f "$PID_FILE"