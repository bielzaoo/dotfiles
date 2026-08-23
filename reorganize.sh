#!/bin/bash
# Roda isso DENTRO do seu repo clonado (~/dotfiles), na raiz, com working tree limpo.
# Reorganiza a estrutura antiga em common/ + profiles/ + archive/, preservando
# histórico do git (usa `git mv`, não `mv` + `git add`).
set -e

echo "== Movendo o que é comum entre perfis para common/ =="
mkdir -p common
git mv nvim common/nvim
git mv kitty common/kitty

echo "== Arquivando o que não é mais usado (mantido como histórico) =="
mkdir -p archive
git mv rofi archive/rofi
git mv nwg-bar archive/nwg-bar

echo "== Preparando profiles/classic/ (hypr e waybar antigos, serão sobrescritos a seguir) =="
mkdir -p profiles/classic
git mv hyprland profiles/classic/hypr
git mv waybar profiles/classic/waybar

echo "== tmux vai para common/ (independe do shell escolhido) =="
mkdir -p common/tmux
git mv tmux/* common/tmux/ 2>/dev/null || true
rmdir tmux 2>/dev/null || true

echo "== Placeholder do perfil quickshell (projeto futuro) =="
mkdir -p profiles/quickshell
touch profiles/quickshell/.gitkeep

echo ""
echo "Reorganização estrutural concluída."
echo "PRÓXIMO PASSO: copiar os arquivos novos (hypr/waybar atualizados, tmux, install.sh, README)"
echo "por cima dessa estrutura — eles vêm num pacote separado. Depois: git add -A && git commit"
