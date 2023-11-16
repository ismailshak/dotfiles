#!/bin/bash

# Get the window ID of the currently focused window
WINDOW_ID=$(yabai -m query --windows --window | jq -re '.id')

# Move window to the requested display
yabai -m window --display "$1"

# Focus the window again
yabai -m window --focus "$WINDOW_ID"
