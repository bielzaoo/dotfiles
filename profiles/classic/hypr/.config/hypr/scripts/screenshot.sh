#!/bin/bash
mkdir -p ~/Pictures/screenshots
filename=~/Pictures/screenshots/$(date +%Y-%m-%d_%H-%M-%S).png
case "$1" in
  full)
    grim "$filename"
    ;;
  area)
    grim -g "$(slurp)" "$filename"
    ;;
esac
wl-copy < "$filename"
notify-send "Screenshot salva" "$filename"
