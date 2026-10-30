#!/bin/sh
# Presets default do rodízio (fonte/cor/espaco) quando ainda não há um ativo.
# Os symlinks *-atual são estado local, fora do git (ver .gitignore).
padrao() { [ -e "$1/$2" ] || ln -sfn "$3" "$1/$2"; }
padrao "$HOME/.config/kitty" fonte-atual.conf  fonts/cozette.conf
padrao "$HOME/.config/kitty" cor-atual.conf    cores/vga.conf
padrao "$HOME/.config/hypr"  espaco-atual.lua  espacos/justo.lua

# Gera o tema do resto do desktop (hypr, waybar, mako, hyprlock, Vicinae) a partir da fonte/cor do kitty
"$HOME/.local/bin/repinta"

# Modo escuro pros apps de fora do repinta: o portal repassa o color-scheme
# (Firefox, Chromium, Electron, GTK4); o gtk-theme cobre os GTK3 (polkit).
# O seletor de arquivos ignora o gsettings: tema dele no pacote portal/.
# Fica no dconf, fora do git, por isso mora aqui.
gsettings set org.gnome.desktop.interface color-scheme prefer-dark
gsettings set org.gnome.desktop.interface gtk-theme Adwaita-dark
# Pastas cinza em vez do azul do Adwaita: gera o tema Papirus-Pastas no usuário
# e aponta o icon-theme pra ele (ver ~/.local/bin/pastas; trocar: `pastas <cor>`)
"$HOME/.local/bin/pastas" grey

# Firefox: Betterfox + overrides no user.js do perfil padrão e o chrome/
# (userChrome.css) linkado nele. O nome da pasta do perfil é aleatório, por
# isso não dá pra linkar pelo stow. Vale no próximo start do Firefox.
ff="$HOME/.config/mozilla/firefox"
perfil=$(sed -n 's/^Default=//p' "$ff/installs.ini" 2>/dev/null | head -n1)
if [ -n "$perfil" ] && [ -d "$ff/$perfil" ]; then
    cat "$ff/betterfox/betterfox.js" "$ff/betterfox/overrides.js" >"$ff/$perfil/user.js"
    # chrome/ do perfil = a pasta versionada (userChrome.css + tema do repinta)
    [ -e "$ff/$perfil/chrome" ] && [ ! -L "$ff/$perfil/chrome" ] &&
        mv "$ff/$perfil/chrome" "$ff/$perfil/chrome.bak"
    ln -sfn ../chrome "$ff/$perfil/chrome"
else
    echo "  aviso: sem perfil do Firefox ainda; abra o Firefox uma vez e rode o setup.sh de novo" >&2
fi

# Pastas padrão da home (Desktop, Pictures, Music...). A unit de usuário do
# xdg-user-dirs só dispara com o graphical-session-pre.target, que esta sessão
# (greetd + Hyprland, sem uwsm) não ativa; o Nautilus monta a barra lateral
# pelo ~/.config/user-dirs.dirs que ele grava.
xdg-user-dirs-update

# Apps padrão. O xdg-mime grava no ~/.config/mimeapps.list, que o Firefox
# também reescreve: por isso aplica aqui, e não como arquivo no stow.
# Os tipos vêm do MimeType= do .desktop de cada app; a ordem importa (o último
# ganha): o zathura-pdf-mupdf também reivindica imagem, então fica só com o que
# não é imagem, e o swayimg vem depois.
mimes() { sed -n 's/^MimeType=//p' "/usr/share/applications/$1" | tr ';' '\n' | grep .; }
padrao_app() { app=$1; shift; [ -f "/usr/share/applications/$app" ] && xdg-mime default "$app" "$@"; }
padrao_app org.pwmt.zathura-pdf-mupdf.desktop $(mimes org.pwmt.zathura-pdf-mupdf.desktop | grep -v '^image/')
padrao_app swayimg.desktop $(mimes swayimg.desktop)
padrao_app mpv.desktop $(mimes mpv.desktop)
padrao_app org.gnome.Nautilus.desktop inode/directory
