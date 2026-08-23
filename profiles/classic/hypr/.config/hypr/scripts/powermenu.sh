#!/bin/bash
ICONS="$HOME/.config/hypr/scripts/icons"
WOFI="wofi --dmenu --allow-images -p"

item() {
    # item <icone> <rotulo>
    echo "img:$ICONS/$1.svg:text:$2"
}

confirm() {
    # confirm "reiniciar" -> pergunta Sim/Não antes de ações destrutivas
    local ans
    ans=$(printf "Sim\nNão" | wofi --dmenu -p "Confirmar $1?")
    [ "$ans" = "Sim" ]
}

choice=$( {
    item "lock"     "Bloquear"
    item "suspend"  "Suspender"
    item "restart"  "Reiniciar"
    item "shutdown" "Desligar"
    item "logout"   "Sair do Hyprland"
} | $WOFI "Energia" | sed 's/^.*text://' )

case "$choice" in
    "Bloquear")
        pidof hyprlock || hyprlock &
        ;;
    "Suspender")
        systemctl suspend &
        ;;
    "Reiniciar")
        confirm "reiniciar" && systemctl reboot &
        ;;
    "Desligar")
        confirm "desligar" && systemctl poweroff &
        ;;
    "Sair do Hyprland")
        confirm "sair do Hyprland" && hyprctl dispatch exit &
        ;;
esac
