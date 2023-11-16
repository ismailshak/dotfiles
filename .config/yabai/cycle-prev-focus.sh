#!/bin/bash
# Cycles prev focus through windows regardless of layout

# Get the current layout
LAYOUT=$(yabai -m query --spaces --space | jq '.type')

# If the current layout is bsp, then use next command
if [[ $LAYOUT == '"bsp"' ]]; then
    yabai -m window --focus prev || yabai -m window --focus last
fi

# If the current layout is stack, then use stack.next command
if [[ $LAYOUT == '"stack"' ]]; then
    yabai -m window --focus stack.prev || yabai -m window --focus stack.last
fi
