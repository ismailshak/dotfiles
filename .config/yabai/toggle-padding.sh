#!/bin/bash
# Cycles through padding for windows in a single space

# Get current space id
SPACE=$(yabai -m query --spaces --space | jq '.index')

# Get the current padding values
TOP_PADDING=$(yabai -m config --space "$SPACE" top_padding)

# If the current padding is 10, then set it to 20
if [[ $TOP_PADDING -eq 0 ]]; then
	yabai -m config --space "$SPACE" top_padding 20
	yabai -m config --space "$SPACE" bottom_padding 20
	yabai -m config --space "$SPACE" left_padding 200
	yabai -m config --space "$SPACE" right_padding 200
	yabai -m config --space "$SPACE" window_gap 20
fi

# If the current padding is 20, then set it to 0
if [[ $TOP_PADDING -eq 20 ]]; then
	yabai -m config --space "$SPACE" top_padding 0
	yabai -m config --space "$SPACE" bottom_padding 0
	yabai -m config --space "$SPACE" left_padding 0
	yabai -m config --space "$SPACE" right_padding 0
	yabai -m config --space "$SPACE" window_gap 0
fi
