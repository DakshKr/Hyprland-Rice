#!/usr/bin/env bash

# A self-contained, toggleable script to launch the Rofi application drawer
# with an embedded theme, using a PID file for precise toggling.

PID_FILE="/tmp/rofi_app_drawer.pid"

# --- Toggling Logic ---
# Check if the PID file exists and if the process it points to is still running.
if [ -f "$PID_FILE" ] && ps -p "$(cat "$PID_FILE")" > /dev/null; then
    # If so, kill that specific Rofi instance. This is the "toggle off" action.
    kill "$(cat "$PID_FILE")"
    exit 0
fi

# --- Theme Definition ---
# The Rofi theme is defined here as a multi-line string.
THEME=$(cat <<EOF
configuration {
    modes: "window,run,ssh,drun";
    sorting-method: "normal";
    show-icons:true;
    matching: "regex";
    drun-match-fields: "name";
    display-run: "Menu:";
    display-ssh: "SSH:";
    display-drun: "Apps:";
    display-window: "Windows:";
}

@theme "tokyo"

* {
    font: "JetBrainsMono Nerd Font 28";
    background-color:   transparent;
    text-color:         @fg0;
    margin:             0px;
    padding:            0px;
    spacing:            0px;
}

window {
    height: 800px;
    location:           center;
    width:              960px;
    y-offset:           -40px;
    border-radius:      24px;
    border: 2px;
    border-color: @bg3;
    background-color:   #1a1b26;
}

mainbox {
    padding: 24px;
}

inputbar {
    background-color:   @bg1;
    border-color:       @bg3;
    border-radius:      24px;
    border:             4px;
    padding:            16px 32px;
    spacing:            16px;
    children:           [ prompt, entry ];
}

prompt {
    text-color: @blue;
}

entry {
    placeholder: "Search";
    placeholder-color: @cyan;
}

message {
    margin:             24px 0 0;
    border-radius:      24px;
    border-color:       @bg2;
    background-color:   @bg2;
}

textbox {
    padding:            16px 48px;
    background-color:   @bg2;
}

listview {
    background-color:   transparent;
    margin:             30px 0 0;
    columns:            1;
    lines:              4;
    fixed-height:       false;
}

element {
    padding:            16px 32px;
    spacing:            16px;
    border-radius:      24px;
    margin:             24px 0 0;
}

element normal urgent {
  text-color: @urgent;
}

element normal active {
    text-color: @accent;
}

element selected normal, element selected active {
    background-color:   @bg2;
}

element-icon {
    size:               2em;
    vertical-align:     0.5;
}

element-text {
    font: "JetBrainsMono Nerd Font 28";
    text-color:         inherit;
}
EOF
)

# --- Main Script Execution ---
# Launch Rofi, telling it to write its PID to our file and passing the theme.
rofi -show drun -theme-str "$THEME" -pid "$PID_FILE"

# --- Cleanup ---
# If rofi exits normally (e.g., user hits Esc or selects an app),
# the PID file might be left over. We remove it here to be safe.
# The check at the top of the script will handle the toggle-off case.
if [ -f "$PID_FILE" ]; then
    rm -f "$PID_FILE"
fi
