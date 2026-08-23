#!/bin/bash
# Uso: ./install.sh classic
#      ./install.sh quickshell   (ainda vazio — projeto futuro)
set -e

PROFILE="$1"

if [ -z "$PROFILE" ]; then
    echo "Uso: ./install.sh <classic|quickshell>"
    exit 1
fi

if ! command -v stow &> /dev/null; then
    echo "GNU Stow não encontrado. Instalando..."
    sudo pacman -S --needed stow
fi

echo "== Aplicando pacotes comuns (nvim, kitty, tmux) =="
for pkg in common/*/; do
    name=$(basename "$pkg")
    echo "  -> $name"
    stow -d common -t "$HOME" "$name"
done

echo "== Aplicando perfil: $PROFILE =="
if [ ! -d "profiles/$PROFILE" ]; then
    echo "Perfil '$PROFILE' não existe em profiles/"
    exit 1
fi

for pkg in "profiles/$PROFILE"/*/; do
    name=$(basename "$pkg")
    echo "  -> $name"
    stow -d "profiles/$PROFILE" -t "$HOME" "$name"
done

echo ""
echo "Pronto! Perfil '$PROFILE' aplicado via symlinks."
echo "Pra trocar de perfil depois: stow -D em cima do atual, depois ./install.sh <outro>"
