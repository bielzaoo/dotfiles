#!/bin/bash
WOFI="wofi --dmenu --allow-images --allow-markup -p"

# Busca ícone no Papirus-Dark; se não achar, usa um genérico
icon() {
    local found
    found=$(find /usr/share/icons/Papirus-Dark -iname "$1.svg" 2>/dev/null | head -1)
    echo "${found:-/usr/share/icons/Papirus-Dark/64x64/mimetypes/application-x-executable.svg}"
}

# Ícone real de webapp (PNG baixado pelo webapp-create via Dashboard Icons)
# Se o PNG não existir ainda, cai pro genérico de internet.
webapp_icon() {
    local slug="$1"
    local path="$HOME/.local/share/webapps/$slug/icon.png"
    if [ -f "$path" ]; then
        echo "$path"
    else
        icon "applications-internet"
    fi
}

item() {
    # item <icone-tema> <rotulo>
    echo "img:$(icon "$1"):text:$2"
}

item_webapp() {
    # item_webapp <slug-do-webapp> <rotulo>
    echo "img:$(webapp_icon "$1"):text:$2"
}

ICONS_DIR="$HOME/.config/hypr/scripts/icons"

categoria=$( {
    echo "img:$ICONS_DIR/ia.svg:text:IA"
    echo "img:$ICONS_DIR/web.svg:text:Web"
    echo "img:$ICONS_DIR/sistema.svg:text:Sistema"
    echo "img:$ICONS_DIR/utilitarios.svg:text:Utilitários"
} | $WOFI "Categoria" | sed 's/^.*text://' )

case "$categoria" in
    "IA")
        app=$( { item_webapp "claude" "Claude"; } | $WOFI "IA" | sed 's/^.*text://' )
        case "$app" in
            "Claude") gtk-launch webapp-claude & ;;
        esac
        ;;
    "Web")
        app=$( {
            item_webapp "whatsapp" "WhatsApp"
            item_webapp "notion"   "Notion"
            item_webapp "spotify"  "Spotify"
        } | $WOFI "Web" | sed 's/^.*text://' )
        case "$app" in
            "WhatsApp") gtk-launch webapp-whatsapp & ;;
            "Notion")   gtk-launch webapp-notion & ;;
            "Spotify")  gtk-launch webapp-spotify & ;;
        esac
        ;;
    "Sistema")
        app=$( {
            item "utilities-system-monitor" "btop"
            item "git"                      "lazygit"
            item "audio-volume-high"        "wiremix"
            item "network-wireless"         "wlctl"
        } | $WOFI "Sistema" | sed 's/^.*text://' )
        case "$app" in
            "btop")    kitty --class btop -e btop & ;;
            "lazygit") kitty --class lazygit -e lazygit & ;;
            "wiremix") kitty --class wiremix -e wiremix & ;;
            "wlctl")   kitty --class wlctl -e wlctl & ;;
        esac
        ;;
    "Utilitários")
        app=$( {
            item "system-file-manager" "Yazi"
            item "applets-screenshooter" "Screenshot área"
            item "edit-paste"          "Histórico clipboard"
        } | $WOFI "Utilitários" | sed 's/^.*text://' )
        case "$app" in
            "Yazi")                kitty --class yazi -e yazi & ;;
            "Screenshot área")     bash ~/.config/hypr/scripts/screenshot.sh area & ;;
            "Histórico clipboard") bash -c 'cliphist list | wofi --dmenu | cliphist decode | wl-copy' & ;;
        esac
        ;;
esac
