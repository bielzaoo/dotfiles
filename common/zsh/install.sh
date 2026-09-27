#!/usr/bin/env bash
# Troca ls por eza e cd por zoxide no zsh, sem stow e sem mexer no resto
# dos dotfiles. Precisa do eza e do zoxide instalados
# (sudo pacman -S eza zoxide).
#
# Uso: bash common/zsh/install.sh   (a partir da raiz do repo)
#      bash ~/dotfiles/common/zsh/install.sh   (de qualquer lugar)
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$HOME/.config/zsh"
ln -sf "$DIR/.config/zsh/modern-cli.zsh" "$HOME/.config/zsh/modern-cli.zsh"

MARKER="# >>> dotfiles modern-cli >>>"
RC="$HOME/.zshrc"
if [ -f "$RC" ] && ! grep -qF "$MARKER" "$RC"; then
    cat >>"$RC" <<'EOF'

# >>> dotfiles modern-cli >>>
[[ -f "$HOME/.config/zsh/modern-cli.zsh" ]] && source "$HOME/.config/zsh/modern-cli.zsh"
# <<< dotfiles modern-cli <<<
EOF
    echo "  -> adicionado ao $RC"
fi

echo "eza/zoxide configurados. Abre um terminal novo (ou 'source ~/.zshrc') pra ativar."
