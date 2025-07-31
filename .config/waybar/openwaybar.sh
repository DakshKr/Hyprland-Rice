#!/bin/bash

# This script toggles Waybar.
# If Waybar is running, it kills it.
# If Waybar is not running, it starts it.

if pgrep -x "waybar" > /dev/null
then
    # If waybar is running, kill the process
    killall waybar
else
    # If waybar is not running, start it
    # The '&' at the end makes it run in the background
    waybar &
fi