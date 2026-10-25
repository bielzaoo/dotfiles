#!/bin/sh
# Presets default do rodízio (fonte/cor/espaco) quando ainda não há um ativo.
# Os symlinks *-atual são estado local, fora do git (ver .gitignore).
padrao() { [ -e "$1/$2" ] || ln -sfn "$3" "$1/$2"; }
padrao "$HOME/.config/kitty" fonte-atual.conf  fonts/cozette.conf
padrao "$HOME/.config/kitty" cor-atual.conf    cores/vga.conf
padrao "$HOME/.config/hypr"  espaco-atual.lua  espacos/justo.lua
