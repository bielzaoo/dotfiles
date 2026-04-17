#!/bin/bash

options="⏻ Desligar\n Reiniciar\n Suspender\n Logout"

chosen=$(
  echo -e "$options" | rofi \
    -dmenu \
    -i \
    -p "Power" \
    -theme ~/.config/rofi/powermenu.rasi
)

case "$chosen" in
"⏻ Desligar")
  poweroff
  ;;
" Reiniciar")
  reboot
  ;;
" Suspender")
  systemctl suspend
  ;;
" Logout")
  hyprctl dispatch exit
  ;;
esac
