#!/bin/bash
# Move windows between spaces in the current display

DIRECTION="$1"
CURRENT_SPACE=$(yabai -m query --spaces --space | jq '.index')
LAST_SPACE=$(yabai -m query --spaces --display | jq 'last | .index')
FIRST_SPACE=$(yabai -m query --spaces --display | jq 'first | .index')

if [ "$DIRECTION" = "next" ]; then
    if [ "$CURRENT_SPACE" = "$LAST_SPACE" ]; then
    yabai -m window --space first
    skhd --key "ctrl - $FIRST_SPACE"
    else
        yabai -m window --space next
        skhd --key "ctrl - right"
    fi
fi


if [ "$DIRECTION" = "prev" ]; then
    if [ "$CURRENT_SPACE" = "$FIRST_SPACE" ]; then
    yabai -m window --space last
    skhd --key "ctrl - $LAST_SPACE"
    else
        yabai -m window --space prev
        skhd --key "ctrl - left"
    fi
fi
