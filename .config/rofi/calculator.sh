#!/usr/bin/env bash

# A self-contained, toggleable script for a Rofi-based calculator
# with an embedded theme, using a PID file for precise toggling.

PID_FILE="/tmp/rofi_calculator.pid"

# --- Toggling Logic ---
# Check if the PID file exists and if the process it points to is still running.
if [ -f "$PID_FILE" ] && ps -p "$(cat "$PID_FILE")" > /dev/null; then
    # If so, kill that specific Rofi instance. This is the "toggle off" action.
    kill "$(cat "$PID_FILE")"
    exit 0
fi

# --- Theme Definition ---
# The Rofi theme is defined here as a multi-line string.
# This theme is styled to match the app drawer for a consistent look.
THEME=$(cat <<EOF
configuration {
    show-icons: false; /* Icons are not needed for the calculator */
    display-calc: "Calculate:"; /* Sets a custom prompt for the calculator mode */
}

@theme "tokyo"

* {
    font: "JetBrainsMono Nerd Font 32"; /* Increased font size */
    background-color:   transparent;
    text-color:         @fg0;
    margin:             0px;
    padding:            0px;
    spacing:            0px;
}

window {
    height: 400px; /* Increased height */
    location:           center;
    width:              1200px; /* Increased width */
    y-offset:           -40px;
    border-radius:      48px; /* Increased border radius for proportion */
    border: 2px;
    border-color: @bg3;
    background-color:   #1a1b26;
    padding: 30px;
}

mainbox {
    padding: 24px;
}

inputbar {
    margin: 0px 0px 70px 0px;
    background-color:   @bg1;
    border-color:       @bg3;
    border-radius:      32px;
    border:             4px;
    padding:            16px 32px;
    spacing:            16px;
    children:           [ entry ];
}

prompt {
    text-color: @blue;
}

entry {
    placeholder: "Enter calculation...";
    placeholder-color: @cyan;
}

EOF
)

# --- Main Script Execution ---
# Launch Rofi in 'calc' mode with flags to simplify the output.
# -no-history: Disables calculation history.
# -terse: Shows only the result, not the full equation.
rofi -show calc -modi calc -theme-str "$THEME" -pid "$PID_FILE" -no-history -terse

# --- Cleanup ---
# If rofi exits normally (e.g., user hits Esc or copies a result),
# the PID file might be left over. We remove it here to be safe.
if [ -f "$PID_FILE" ]; then
    rm -f "$PID_FILE"
fi
