#!/bin/bash
# Uso: ./install.sh classic
#      ./install.sh quickshell
#
# Reflete a estrutura real do repo em 29/08/2026. Se a estrutura mudar de
# novo no futuro (novo profile, pacote dividido/unificado), este script
# provavelmente precisa ser atualizado junto — não é "fire and forget".
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

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_DIR"

echo "== Aplicando pacotes comuns (common/) =="
if [ -d common ] && [ -n "$(ls -A common 2>/dev/null)" ]; then
    for pkg in common/*/; do
        name=$(basename "$pkg")
        echo "  -> $name"
        stow -d common -t "$HOME" "$name"
    done
else
    echo "  (common/ vazio ou inexistente — nada a aplicar via Stow aqui."
    echo "   nvim, por exemplo, é sempre instalado fresh via LazyVim, de propósito"
    echo "   fora do escopo do Stow — ver CLAUDE.md.)"
fi

echo ""
echo "== Aplicando perfil: $PROFILE =="

case "$PROFILE" in
    classic)
        if [ ! -d profiles/classic/hypr ]; then
            echo "ERRO: profiles/classic/hypr não encontrado."
            exit 1
        fi
        ( cd profiles/classic && stow -v -t "$HOME" hypr )
        ;;
    quickshell)
        # Pacote único "achatado": .config/quickshell, .config/kitty,
        # .config/starship.toml e .tmux.conf todos dentro de profiles/quickshell/,
        # stowados de uma vez (não é um pacote por subpasta).
        if [ ! -d profiles/quickshell ]; then
            echo "ERRO: profiles/quickshell não encontrado."
            exit 1
        fi
        ( cd profiles && stow -v -t "$HOME" quickshell )
        ;;
    *)
        echo "Perfil '$PROFILE' desconhecido. Use 'classic' ou 'quickshell'."
        exit 1
        ;;
esac

echo ""
echo "== Passos manuais que o Stow NÃO cobre (fora de \$HOME, fora do alcance dele) =="
echo ""

if [ "$PROFILE" = "quickshell" ]; then
    echo "1. PAM pro lock screen novo (⚠️ WIP — LockScreen.qml/IdleService.qml existem"
    echo "   no repo mas NÃO estão carregados no shell.qml, ver CLAUDE.md pro motivo:"
    echo "   pam.respond() não destravava a sessão, incidente real de lock-out)."
    echo "   Se/quando for reativar:"
    echo "     sudo cp /etc/pam.d/hyprlock /etc/pam.d/quickshell-lock"
    echo ""
fi

echo "2. Tema Plymouth (bootlog-cyan) — ⚠️ NÃO testado em boot real ainda:"
echo "     sudo cp -r profiles/plymouth/usr/share/plymouth/themes/bootlog-cyan /usr/share/plymouth/themes/"
echo "   Precisa também editar mkinitcpio.conf (hook 'plymouth', ANTES de 'encrypt')"
echo "   e adicionar 'splash' na entrada do systemd-boot. Ver CLAUDE.md antes de mexer."
echo ""
echo "3. Neovim: sempre instalado fresh via LazyVim (https://lazyvim.org), não"
echo "   gerenciado por este script nem pelo Stow, de propósito."
echo ""
echo "== Pronto! Perfil '$PROFILE' aplicado via symlinks. =="
echo ""
echo "Pra trocar de perfil depois, desfaça o Stow do atual antes de aplicar outro:"
echo "  classic:    (cd profiles/classic && stow -D -t ~ hypr)"
echo "  quickshell: (cd profiles && stow -D -t ~ quickshell)"
