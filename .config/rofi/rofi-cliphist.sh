#!/usr/bin/env bash

# A more robust, toggleable Rofi-based clipboard manager using a PID file.

PID_FILE="/tmp/rofi_clipboard.pid"

# --- Toggling Logic ---
# Check if the PID file exists and if the process it points to is still running.
if [ -f "$PID_FILE" ] && ps -p "$(cat "$PID_FILE")" > /dev/null; then
    # If so, kill that specific Rofi instance. This is the "toggle off" action.
    kill "$(cat "$PID_FILE")"
    exit 0
fi

# --- Main Loop ---
# This loop allows the user to delete items from the clipboard history
# and have the Rofi menu refresh automatically without closing.
while true; do
    # We ask Rofi to write its Process ID (PID) to our file using the `-pid` flag.
    # This allows us to specifically target this Rofi instance for toggling.
    SELECTION=$(cliphist list | rofi \
        -dmenu \
        -p "Clipboard" \
        -theme ~/.config/rofi/clipboard.rasi \
        -kb-remove-char-forward "" \
        -kb-custom-1 "Delete" \
        -pid "$PID_FILE")

    EXIT_CODE=$?

    case $EXIT_CODE in
        0) # User pressed Enter: Copy selection to clipboard.
            echo "$SELECTION" | cliphist decode | wl-copy
            break # Exit the loop after copying.
            ;;
        1) # User pressed Escape: Do nothing.
            break # Exit the loop.
            ;;
        10) # User pressed the custom keybind for "Delete".
            echo "$SELECTION" | cliphist delete
            # The loop will now restart, refreshing the list shown in Rofi.
            ;;
        *) # An unexpected exit code.
            # We break here to prevent any strange infinite loops.
            break
            ;;
    esac
done

# --- Cleanup ---
# Ensure the PID file is removed when the script exits, so it's ready for the next launch.
rm -f "$PID_FILE"
