#!/bin/bash
# Rotates windows counterclockwise through bsp layout

WIN=$(yabai -m query --windows --window first | jq '.id')

while : ; do
    yabai -m window "$WIN" --swap next &> /dev/null
    if [[ $? -eq 1 ]]; then
        break
    fi
done
