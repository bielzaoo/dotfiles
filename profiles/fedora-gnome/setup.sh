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
# - Terminal: kitty + tmux + zsh com prompt próprio (no lugar do starship),
#   autosuggestions, syntax highlighting, eza e zoxide
#
# Configs do GNOME vão por gsettings (o GNOME guarda no dconf, não em
# arquivo), então é idempotente e pode rodar de novo.
#
# Uso: bash ~/dotfiles/profiles/fedora-gnome/setup.sh
#      (não use ./install.sh fedora-gnome: ele é feito pro Arch)
#
# Variáveis opcionais:
#   SKIP_PACKAGES=1         não instala nada (só aplica as configs)
#   INSTALL_NERD_SYMBOLS=1  baixa os ícones da Nerd Font do GitHub (fora
#                           dos repositórios do Fedora; ver mais abaixo)
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
        kitty tmux zsh zsh-autosuggestions zsh-syntax-highlighting \
        eza zoxide fzf stow

    # Flatpaks rodam isolados e não enxergam o adw-gtk3 do dnf: precisa da
    # versão do tema como extensão do Flathub.
    if command -v flatpak &>/dev/null; then
        flatpak install -y --noninteractive flathub \
            org.gtk.Gtk3theme.adw-gtk3 org.gtk.Gtk3theme.adw-gtk3-dark
    fi
fi

if command -v flatpak &>/dev/null; then
    echo "== Flatpak: tema adw-gtk3-dark nos apps em sandbox =="
    flatpak override --user --env=GTK_THEME=adw-gtk3-dark
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

if [ -n "$INSTALL_NERD_SYMBOLS" ]; then
    # Opcional (foge do "só repositório oficial"): só os ícones da Nerd Font,
    # sem script, direto da release oficial e conferido pelo SHA-256 dela.
    # O texto continua na JetBrains Mono do Fedora; o fontconfig/ só faz os
    # ícones virem dessa fonte. O kitty não precisa, já tem os símbolos.
    echo "== Ícones da Nerd Font (Symbols Nerd Font) =="
    NF_VERSION=v3.5.1
    NF_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/$NF_VERSION"
    NF_TMP=$(mktemp -d)
    curl -fsSL -o "$NF_TMP/NerdFontsSymbolsOnly.tar.xz" "$NF_URL/NerdFontsSymbolsOnly.tar.xz"
    curl -fsSL -o "$NF_TMP/SHA-256.txt" "$NF_URL/SHA-256.txt"
    (cd "$NF_TMP" && grep ' NerdFontsSymbolsOnly.tar.xz$' SHA-256.txt | sha256sum -c --quiet)
    mkdir -p "$HOME/.local/share/fonts/NerdFontsSymbolsOnly"
    tar -xJf "$NF_TMP/NerdFontsSymbolsOnly.tar.xz" -C "$HOME/.local/share/fonts/NerdFontsSymbolsOnly" \
        SymbolsNerdFont-Regular.ttf SymbolsNerdFontMono-Regular.ttf LICENSE
    rm -rf "$NF_TMP"
    stow --no-folding -d "$DIR" -t "$HOME" fontconfig
    fc-cache -f >/dev/null
fi

echo "== Ptyxis (terminal padrão do GNOME): mesmo visual do kitty =="
# A paleta vai como arquivo; o resto (fonte, perfil) é gsettings. Padding
# não é configurável no Ptyxis, só liga/desliga, então fica o padrão dele.
stow --no-folding -d "$DIR" -t "$HOME" ptyxis
PTYXIS_FONT='JetBrains Mono 11'
fc-list | grep -q "JetBrainsMono Nerd Font" && PTYXIS_FONT='JetBrainsMono Nerd Font 11'
set_key org.gnome.Ptyxis use-system-font false
set_key org.gnome.Ptyxis font-name "$PTYXIS_FONT"
set_key org.gnome.Ptyxis interface-style 'dark'
PTYXIS_PROFILE=$(gsettings get org.gnome.Ptyxis default-profile-uuid 2>/dev/null | tr -d "'")
if [ -n "$PTYXIS_PROFILE" ]; then
    set_key "org.gnome.Ptyxis.Profile:/org/gnome/Ptyxis/Profiles/$PTYXIS_PROFILE/" palette 'vantablack'
fi

echo "== tmux =="
# Keybinds do Omarchy + tema tokyo-night-black (ver common/tmux).
stow --no-folding -d "$REPO/common" -t "$HOME" tmux

echo "== zsh: prompt, plugins, eza/zoxide =="
stow --no-folding -d "$DIR" -t "$HOME" zsh
if [ ! -e "$HOME/.zshrc" ]; then
    cp "$DIR/zshrc" "$HOME/.zshrc"
    echo "  -> ~/.zshrc criado"
fi
bash "$REPO/common/zsh/install.sh"

# O kitty já força o zsh no kitty.conf, mas o Ptyxis e o tmux abrem a shell
# de login.
ZSH_BIN=$(command -v zsh)
if [ "$(getent passwd "$USER" | cut -d: -f7)" != "$ZSH_BIN" ]; then
    echo "== Shell de login: zsh (pede a sua senha) =="
    chsh -s "$ZSH_BIN" || echo "  aviso: rode 'chsh -s $ZSH_BIN' depois" >&2
fi

echo "== ssh-agent: um agente só pras shells e pros apps gráficos =="
bash "$REPO/common/ssh-agent/install.sh"

echo ""
echo "Pronto! Faça logout/login pra carregar as extensões (no Wayland o"
echo "GNOME só lê extensões novas numa sessão nova), a shell nova e o"
echo "ssh-agent nos apps abertos pelo menu."
