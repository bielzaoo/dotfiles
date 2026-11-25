#!/usr/bin/env bash
# Troca ls por eza, cd por zoxide, põe o prompt do starship e um Tab que
# ignora maiúscula/minúscula (.inputrc) no bash, sem
# stow e sem mexer no resto do ~/.bashrc. Precisa do eza, zoxide e starship
# (Arch: sudo pacman -S eza zoxide starship bash-completion).
#
# Uso: bash ~/dotfiles/common/bash/install.sh
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$DIR/../.." && pwd)"

mkdir -p "$HOME/.config/bash"
ln -sf "$DIR/.config/bash/modern-cli.bash" "$HOME/.config/bash/modern-cli.bash"
# Tab que ignora maiúscula/minúscula etc. (ver .inputrc)
ln -sf "$DIR/.inputrc" "$HOME/.inputrc"
# Config do prompt (common/starship), se ainda não houver uma
[ -e "$HOME/.config/starship.toml" ] || \
    ln -s "$REPO/common/starship/.config/starship.toml" "$HOME/.config/starship.toml"

MARKER="# >>> dotfiles modern-cli >>>"
RC="$HOME/.bashrc"
if [ -f "$RC" ] && ! grep -qF "$MARKER" "$RC"; then
    cat >>"$RC" <<'EOT'

# >>> dotfiles modern-cli >>>
[[ -f "$HOME/.config/bash/modern-cli.bash" ]] && source "$HOME/.config/bash/modern-cli.bash"
# <<< dotfiles modern-cli <<<
EOT
    echo "  -> adicionado ao $RC"
fi

[ -f /usr/share/bash-completion/bash_completion ] || \
    echo "  aviso: bash-completion não instalado (sudo pacman -S bash-completion)" >&2
for cmd in eza zoxide starship; do
    command -v "$cmd" &>/dev/null || echo "  aviso: $cmd não instalado (sudo pacman -S $cmd)" >&2
done
echo "eza/zoxide/starship configurados no bash. Abre um terminal novo pra ativar."
