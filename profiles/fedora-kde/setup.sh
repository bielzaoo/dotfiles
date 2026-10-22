#!/usr/bin/env bash
# Fedora KDE Plasma no mesmo espírito do fedora-gnome: escuro, leve e sem
# nada exorbitante. Tudo vem dos repositórios oficiais do Fedora (sem COPR,
# sem `curl | sh`, sem temas baixados da KDE Store).
#
# - Plasma: Breeze Dark (o do Fedora, com o wallpaper dele), ícones
#   Papirus-Dark, janelas novas no centro
# - Painéis: barra fina no topo (menu, relógio no centro, bandeja) + dock
#   flutuante embaixo, que some quando uma janela encosta
# - Terminal: Konsole com o visual do kitty (Vantablack) + kitty, tmux e zsh
#   iguais aos do fedora-gnome
#
# Não usa stow pras configs do KDE: ele reescreve kwinrc/kdeglobals/konsolerc
# no lugar e quebraria os symlinks. Vai tudo por kwriteconfig6/D-Bus, então
# é idempotente e pode rodar de novo. Só o esquema de cores do Konsole, que
# o KDE só lê, é symlink.
#
# Uso: bash ~/dotfiles/profiles/fedora-kde/setup.sh
#      (não use ./install.sh: ele é feito pro Arch)
#
# Variáveis opcionais:
#   SKIP_PACKAGES=1         não instala nada (só aplica as configs)
#   SKIP_PANELS=1           não recria os painéis (preserva widgets que você
#                           adicionou na mão depois)
#   INSTALL_NERD_SYMBOLS=1  baixa os ícones da Nerd Font do GitHub (fora dos
#                           repositórios do Fedora; sem eles o Konsole mostra
#                           quadradinhos no lugar dos ícones do prompt)
#
# Instalar pacotes precisa de sudo: rode num terminal interativo.
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$DIR/../.." && pwd)"
# zsh, prompt, zshrc e ícones da Nerd Font são os mesmos do perfil do GNOME.
FEDORA="$REPO/profiles/fedora-gnome"

QDBUS=$(command -v qdbus6 || command -v qdbus-qt6)

if [ -z "$SKIP_PACKAGES" ]; then
    echo "== Instalando pacotes (só repositórios oficiais do Fedora) =="
    sudo dnf install -y --repo=fedora --repo=updates \
        papirus-icon-theme jetbrains-mono-fonts-all breeze-gtk \
        kitty tmux zsh zsh-autosuggestions zsh-syntax-highlighting \
        eza zoxide fzf stow

    # Flatpaks rodam isolados e não enxergam o tema GTK do dnf: precisa da
    # versão do tema como extensão do Flathub.
    if command -v flatpak &>/dev/null; then
        flatpak install -y --noninteractive flathub \
            org.gtk.Gtk3theme.adw-gtk3 org.gtk.Gtk3theme.adw-gtk3-dark
    fi
fi

if command -v flatpak &>/dev/null; then
    echo "== Flatpak: tema adw-gtk3-dark nos apps GTK em sandbox =="
    flatpak override --user --env=GTK_THEME=adw-gtk3-dark
fi

echo "== Tema global: Breeze Dark =="
# O "Fedora Dark" é o Breeze Dark com o wallpaper do Fedora.
if [ -d /usr/share/plasma/look-and-feel/org.fedoraproject.fedoradark.desktop ]; then
    plasma-apply-lookandfeel -a org.fedoraproject.fedoradark.desktop
else
    plasma-apply-lookandfeel -a org.kde.breezedark.desktop
fi

# Depois do tema global, que volta os ícones pro Breeze.
if [ -d /usr/share/icons/Papirus-Dark ]; then
    echo "== Ícones: Papirus-Dark =="
    /usr/libexec/plasma-changeicons Papirus-Dark
fi

echo "== Janelas: minimizar/maximizar/fechar à direita, abrir no centro =="
kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key ButtonsOnRight IAX
kwriteconfig6 --file kwinrc --group Windows --key Placement Centered
"$QDBUS" org.kde.KWin /KWin reconfigure

if [ -z "$SKIP_PANELS" ]; then
    echo "== Painéis: barra fina no topo + dock =="
    "$QDBUS" org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "$(cat "$DIR/panels.js")"
fi

if [ -n "$INSTALL_NERD_SYMBOLS" ]; then
    echo "== Ícones da Nerd Font (Symbols Nerd Font) =="
    bash "$FEDORA/nerd-symbols.sh"
fi

echo "== Konsole: mesmo visual do kitty =="
stow --no-folding -d "$DIR" -t "$HOME" konsole
KONSOLE_FONT='JetBrains Mono'
fc-list | grep -q "JetBrainsMono Nerd Font" && KONSOLE_FONT='JetBrainsMono Nerd Font'
PROFILE="$HOME/.local/share/konsole/Vantablack.profile"
kwriteconfig6 --file "$PROFILE" --group General --key Name Vantablack
kwriteconfig6 --file "$PROFILE" --group General --key Parent FALLBACK/
kwriteconfig6 --file "$PROFILE" --group General --key Command "$(command -v zsh || echo /bin/bash)"
kwriteconfig6 --file "$PROFILE" --group Appearance --key ColorScheme Vantablack
kwriteconfig6 --file "$PROFILE" --group Appearance --key Font "$KONSOLE_FONT,11,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"
kwriteconfig6 --file "$PROFILE" --group Scrolling --key HistorySize 10000
kwriteconfig6 --file konsolerc --group "Desktop Entry" --key DefaultProfile Vantablack.profile
# Sem barra de menu (Ctrl+Shift+M mostra de novo).
kwriteconfig6 --file konsolerc --group KonsoleWindow --key ShowMenuBarByDefault false

echo "== kitty =="
# --no-folding: ~/.config/kitty vira pasta de verdade (só os arquivos são
# links), assim o local.conf abaixo não cai dentro do repo.
stow --no-folding -d "$REPO/common" -t "$HOME" kitty
if ! fc-list | grep -q "JetBrainsMono Nerd Font"; then
    # A Nerd Font não está nos repositórios do Fedora. Usa a JetBrains Mono
    # oficial; os ícones vêm dos símbolos Nerd Font embutidos no kitty.
    echo 'font_family family="JetBrains Mono"' >"$HOME/.config/kitty/local.conf"
fi

echo "== Web apps (sites como apps, ver common/webapps) =="
stow --no-folding -d "$REPO/common" -t "$HOME" webapps
command -v google-chrome &>/dev/null && "$HOME/.local/bin/webapp" sync ||
    echo "  aviso: sem Google Chrome; rode 'webapp sync' depois de instalar" >&2

echo "== tmux =="
stow --no-folding -d "$REPO/common" -t "$HOME" tmux

echo "== zsh: prompt, plugins, eza/zoxide =="
stow --no-folding -d "$FEDORA" -t "$HOME" zsh
if [ ! -e "$HOME/.zshrc" ]; then
    cp "$FEDORA/zshrc" "$HOME/.zshrc"
    echo "  -> ~/.zshrc criado"
fi
bash "$REPO/common/zsh/install.sh"

# O Konsole e o kitty já abrem o zsh direto, mas o tmux abre a shell de login.
ZSH_BIN=$(command -v zsh)
if [ "$(getent passwd "$USER" | cut -d: -f7)" != "$ZSH_BIN" ]; then
    echo "== Shell de login: zsh (pede a sua senha) =="
    chsh -s "$ZSH_BIN" || echo "  aviso: rode 'chsh -s $ZSH_BIN' depois" >&2
fi

echo "== ssh-agent: um agente só pras shells e pros apps gráficos =="
bash "$REPO/common/ssh-agent/install.sh"

echo ""
echo "Pronto! Faça logout/login pra shell nova e pro ssh-agent valerem nos"
echo "apps abertos pelo menu."
