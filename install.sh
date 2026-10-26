#!/bin/bash
# Uso: ./install.sh main       (Arch + Hyprland, perfil principal)
#      ./install.sh classic
#      ./install.sh kde          (KDE Plasma: tema, dock, animações)
#      ./install.sh quickshell   (ainda vazio — projeto futuro)
set -e

PROFILE="$1"

if [ -z "$PROFILE" ]; then
    echo "Uso: ./install.sh <main|classic|kde|quickshell>"
    exit 1
fi

if ! command -v stow &> /dev/null; then
    echo "GNU Stow não encontrado. Instalando..."
    sudo pacman -S --needed stow
fi

# profiles/<perfil>/common.skip: pacotes de common/ que o perfil substitui
# ou não quer
SKIP="profiles/$PROFILE/common.skip"
skipped() { [ -f "$SKIP" ] && grep -qx "$1" "$SKIP"; }

echo "== Aplicando pacotes comuns =="
# Pacote com install.sh é instalador, não pacote de stow (linkar todos daria
# conflito em ~/install.sh). ssh-agent e zsh rodam no fim; plymouth, qemu e
# wireguard mexem no sistema e são na mão (ver README).
for pkg in common/*/; do
    name=$(basename "$pkg")
    if skipped "$name"; then
        echo "  -- $name (pulado pelo perfil)"
        continue
    fi
    if [ -f "$pkg/install.sh" ]; then
        continue
    fi
    echo "  -> $name"
    stow -d common -t "$HOME" "$name"
done

echo "== Aplicando perfil: $PROFILE =="
if [ ! -d "profiles/$PROFILE" ]; then
    echo "Perfil '$PROFILE' não existe em profiles/"
    exit 1
fi

for pkg in "profiles/$PROFILE"/*/; do
    [ -d "$pkg" ] || continue
    name=$(basename "$pkg")
    # system/ é espelho de / (vai pra /etc, /usr via bootstrap.sh), não do $HOME
    [ "$name" = system ] && continue
    echo "  -> $name"
    stow -d "profiles/$PROFILE" -t "$HOME" "$name"
done

if [ -x "profiles/$PROFILE/setup.sh" ]; then
    echo "== Rodando setup do perfil $PROFILE =="
    bash "profiles/$PROFILE/setup.sh"
fi

if ! skipped ssh-agent; then
    echo "== Configurando SSH agent (systemd --user) =="
    bash common/ssh-agent/install.sh
fi

if ! skipped zsh; then
    echo "== Configurando zsh (eza + zoxide) =="
    bash common/zsh/install.sh
fi

echo ""
echo "Pronto! Perfil '$PROFILE' aplicado via symlinks."
echo "Pra trocar de perfil depois: stow -D em cima do atual, depois ./install.sh <outro>"
