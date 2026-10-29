#!/bin/sh
# Autostart agnóstico de compositor: qualquer compositor Wayland com layer-shell
# chama este script. Nada aqui pode depender do Hyprland.

# Login gráfico (greetd) não lê o ~/.bashrc
case ":$PATH:" in *":$HOME/.local/bin:"*) ;; *) export PATH="$HOME/.local/bin:$PATH" ;; esac

waybar &
mako &
bateria &         # aviso de bateria baixa (20% / 10%) via mako
vicinae server &   # launcher + histórico do clipboard (layer-shell, agnóstico)

# Wallpaper: tela de boot (fundo-atual.png, regerado pelo `fundo` a cada login
# pra pegar kernel e services novos); sem PNG, cor sólida do fundo da paleta
awww-daemon &
(
    sleep 0.5
    png="$HOME/.config/session/fundo-atual.png"
    if fundo regera >/dev/null 2>&1 || [ -f "$png" ]; then awww img "$png"
    else awww clear "$(cat "$HOME/.config/session/fundo-atual" 2>/dev/null || echo 000000)"; fi
) &
