#!/usr/bin/env bash
# Ativa só o ssh-agent (systemd --user socket-activation + auto ssh-add
# no login), sem stow e sem mexer no resto dos dotfiles.
#
# Uso: bash common/ssh-agent/install.sh   (a partir da raiz do repo)
#      bash ~/dotfiles/common/ssh-agent/install.sh   (de qualquer lugar)
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$HOME/.local/bin"
ln -sf "$DIR/.local/bin/ssh-agent-setup" "$HOME/.local/bin/ssh-agent-setup"
ln -sf "$DIR/.local/bin/ssh-agent-init" "$HOME/.local/bin/ssh-agent-init"

"$HOME/.local/bin/ssh-agent-setup"

MARKER="# >>> dotfiles ssh-agent >>>"
for RC in "$HOME/.bashrc" "$HOME/.zshrc"; do
    if [ -f "$RC" ] && ! grep -qF "$MARKER" "$RC"; then
        cat >>"$RC" <<'EOF'

# >>> dotfiles ssh-agent >>>
[[ -f "$HOME/.local/bin/ssh-agent-init" ]] && source "$HOME/.local/bin/ssh-agent-init"
# <<< dotfiles ssh-agent <<<
EOF
        echo "  -> adicionado ao $RC"
    fi
done

echo "ssh-agent configurado. Abre um terminal novo (ou 'source ~/.bashrc' / 'source ~/.zshrc') pra ativar."
