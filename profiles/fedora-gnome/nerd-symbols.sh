#!/usr/bin/env bash
# Baixa só os ícones da Nerd Font (Symbols Nerd Font), sem script, direto
# da release oficial no GitHub e conferido pelo SHA-256 dela. Foge do "só
# repositório oficial do Fedora", por isso os setups só rodam isto com
# INSTALL_NERD_SYMBOLS=1. O texto continua na JetBrains Mono do Fedora; o
# fontconfig/ só faz os ícones virem dessa fonte. O kitty não precisa, já
# tem os símbolos embutidos; Ptyxis e Konsole precisam.
#
# Uso: bash ~/dotfiles/profiles/fedora-gnome/nerd-symbols.sh
#      (os setups do fedora-gnome e do fedora-kde chamam este script)
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

NF_VERSION=v3.5.1
NF_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/$NF_VERSION"
NF_TMP=$(mktemp -d)
trap 'rm -rf "$NF_TMP"' EXIT
curl -fsSL -o "$NF_TMP/NerdFontsSymbolsOnly.tar.xz" "$NF_URL/NerdFontsSymbolsOnly.tar.xz"
curl -fsSL -o "$NF_TMP/SHA-256.txt" "$NF_URL/SHA-256.txt"
(cd "$NF_TMP" && grep ' NerdFontsSymbolsOnly.tar.xz$' SHA-256.txt | sha256sum -c --quiet)
mkdir -p "$HOME/.local/share/fonts/NerdFontsSymbolsOnly"
tar -xJf "$NF_TMP/NerdFontsSymbolsOnly.tar.xz" -C "$HOME/.local/share/fonts/NerdFontsSymbolsOnly" \
    SymbolsNerdFont-Regular.ttf SymbolsNerdFontMono-Regular.ttf LICENSE
stow --no-folding -d "$DIR" -t "$HOME" fontconfig
fc-cache -f >/dev/null
