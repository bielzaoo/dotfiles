#!/bin/sh
# Autostart agnóstico de compositor: qualquer compositor Wayland com layer-shell
# chama este script. Nada aqui pode depender do Hyprland.

# Login gráfico (greetd) não lê o ~/.bashrc
case ":$PATH:" in *":$HOME/.local/bin:"*) ;; *) export PATH="$HOME/.local/bin:$PATH" ;; esac

waybar &
mako &
vicinae server &   # launcher + histórico do clipboard (layer-shell, agnóstico)

# Wallpaper: cor sólida = fundo da paleta ativa (fundo-atual, gerado pelo repinta)
awww-daemon &
sleep 0.5 && awww clear "$(cat "$HOME/.config/session/fundo-atual" 2>/dev/null || echo 000000)" &
