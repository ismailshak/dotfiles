#!/bin/bash
# Rotates windows clockwise through bsp layout

WIN=$(yabai -m query --windows --window last | jq '.id')

while : ; do
    yabai -m window "$WIN" --swap prev &> /dev/null
    if [[ $? -eq 1 ]]; then
        break
    fi
done
