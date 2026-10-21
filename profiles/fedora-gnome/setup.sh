#!/usr/bin/env bash
# Visual leve e moderno pro Fedora Workstation (GNOME), no tema escuro, sem
# sair do que é oficial: tudo vem dos repositórios do próprio Fedora
# (assinados, conferidos pelo dnf), sem COPR, sem `curl | sh` e sem temas
# baixados de site. Extensões do GNOME rodam dentro do gnome-shell sem
# sandbox, então ficam só duas: ícones da bandeja e dock.
#
# - GNOME: modo escuro, apps GTK3 iguais aos libadwaita (adw-gtk3),
#   ícones Papirus-Dark, botões minimizar/maximizar, janelas novas no centro
# - Extensões: AppIndicator (bandeja) + Dash to Dock (dock embaixo, some
#   quando uma janela encosta)
# - Terminal: kitty + zsh com prompt próprio (no lugar do starship),
#   autosuggestions, syntax highlighting, eza e zoxide
#
# Configs do GNOME vão por gsettings (o GNOME guarda no dconf, não em
# arquivo), então é idempotente e pode rodar de novo.
#
# Uso: bash ~/dotfiles/profiles/fedora-gnome/setup.sh
#      (não use ./install.sh fedora-gnome: ele é feito pro Arch)
#
# Variáveis opcionais:
#   SKIP_PACKAGES=1  não instala nada (só aplica as configs)
#
# Instalar pacotes precisa de sudo: rode num terminal interativo.
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$DIR/../.." && pwd)"

# Chave que não existe (ex.: extensão mudou de versão) só avisa, não aborta.
set_key() {
    gsettings set "$@" 2>/dev/null || echo "  aviso: não deu pra aplicar: $*" >&2
}

enable_extension() {
    local uuid="$1" cur
    cur=$(gsettings get org.gnome.shell enabled-extensions)
    [[ $cur == *"'$uuid'"* ]] && return
    if [[ $cur == "@as []" || $cur == "[]" ]]; then
        cur="['$uuid']"
    else
        cur="${cur%]}, '$uuid']"
    fi
    gsettings set org.gnome.shell enabled-extensions "$cur"
}

if [ -z "$SKIP_PACKAGES" ]; then
    echo "== Instalando pacotes (só repositórios oficiais do Fedora) =="
    sudo dnf install -y --repo=fedora --repo=updates \
        gnome-tweaks gnome-extensions-app \
        adw-gtk3-theme papirus-icon-theme jetbrains-mono-fonts-all \
        gnome-shell-extension-appindicator gnome-shell-extension-dash-to-dock \
        kitty zsh zsh-autosuggestions zsh-syntax-highlighting \
        eza zoxide fzf stow
fi

echo "== GNOME: modo escuro, adw-gtk3, Papirus-Dark =="
set_key org.gnome.desktop.interface color-scheme 'prefer-dark'
set_key org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark'
set_key org.gnome.desktop.interface icon-theme 'Papirus-Dark'
set_key org.gnome.desktop.interface clock-show-weekday true
set_key org.gnome.desktop.interface show-battery-percentage true

echo "== Janelas: minimizar/maximizar/fechar, abrir no centro =="
set_key org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'
set_key org.gnome.mutter center-new-windows true

echo "== Extensões: AppIndicator + Dash to Dock =="
set_key org.gnome.shell disable-user-extensions false
enable_extension appindicatorsupport@rgcjonas.gmail.com
enable_extension dash-to-dock@micxgx.gmail.com

# Dock discreta: embaixo, some quando uma janela encosta, fundo que fica
# transparente sem janela perto, sem lixeira/discos.
DOCK=org.gnome.shell.extensions.dash-to-dock
set_key $DOCK dock-position 'BOTTOM'
set_key $DOCK dock-fixed false
set_key $DOCK intellihide true
set_key $DOCK extend-height false
set_key $DOCK dash-max-icon-size 40
set_key $DOCK transparency-mode 'DYNAMIC'
set_key $DOCK running-indicator-style 'DOTS'
set_key $DOCK click-action 'minimize-or-previews'
set_key $DOCK show-trash false
set_key $DOCK show-mounts false

echo "== kitty =="
# --no-folding: ~/.config/kitty vira pasta de verdade (só os arquivos são
# links), assim o local.conf abaixo não cai dentro do repo.
stow --no-folding -d "$REPO/common" -t "$HOME" kitty
if ! fc-list | grep -q "JetBrainsMono Nerd Font"; then
    # A Nerd Font não está nos repositórios do Fedora. Usa a JetBrains Mono
    # oficial; os ícones vêm dos símbolos Nerd Font embutidos no kitty.
    echo 'font_family family="JetBrains Mono"' >"$HOME/.config/kitty/local.conf"
fi

echo "== zsh: prompt, plugins, eza/zoxide =="
stow --no-folding -d "$DIR" -t "$HOME" zsh
if [ ! -e "$HOME/.zshrc" ]; then
    cp "$DIR/zshrc" "$HOME/.zshrc"
    echo "  -> ~/.zshrc criado"
fi
bash "$REPO/common/zsh/install.sh"

echo ""
echo "Pronto! Faça logout/login pra carregar as extensões (no Wayland o"
echo "GNOME só lê extensões novas numa sessão nova)."
