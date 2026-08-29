#!/bin/bash
zoom=$(hyprctl getoption cursor:zoom_factor | grep 'float:' | awk '{print $2}')
new_zoom=$(awk "BEGIN {print $zoom $1}")

# trava mínimo em 1.0
if (( $(echo "$new_zoom < 1" | bc -l) )); then
    new_zoom=1.0
fi

hyprctl eval "hl.config({ cursor = { zoom_factor = $new_zoom } })"
