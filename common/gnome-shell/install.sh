#!/usr/bin/env bash
# Extensões e visual do GNOME Shell (Arch + GNOME, mas não depende de distro):
#
# - Dhruva Dock: dock flutuante estilo macOS (preset "macOS Dock" da própria
#   extensão), mais transparente, com blur e o logo do Arch no botão do menu
# - Blur my Shell: painel de cima translúcido (blur só no painel; o da dock
#   fica com a Dhruva, senão os dois brigam)
# - AppIndicator: ícones de bandeja (Discord, Steam...)
# - Clipboard Indicator: histórico do que foi copiado (30 itens, sem notificação)
# - Caffeine: botão no menu rápido que impede a tela de apagar/suspender
# - Just Perfection: só pra deixar o painel de cima mais fino (26px)
#
# As extensões vêm do extensions.gnome.org, na versão feita pro GNOME
# instalado. Elas rodam dentro do gnome-shell sem sandbox: confira a página
# de cada uma antes de adicionar outra aqui.
#
# As configs vão por gsettings (o GNOME guarda no dconf, não em arquivo),
# então é idempotente e pode rodar de novo. No Wayland a extensão nova só
# carrega depois de sair e entrar na sessão: as configs já ficam salvas antes.
#
# Uso: bash ~/dotfiles/common/gnome-shell/install.sh
#   SKIP_DOWNLOAD=1  não baixa/instala nada (só reaplica as configs)
set -e

EXT_DIR="$HOME/.local/share/gnome-shell/extensions"
EXTENSIONS=(
    dhruva@narkagni
    blur-my-shell@aunetx
    appindicatorsupport@rgcjonas.gmail.com
    clipboard-indicator@tudmotu.com
    caffeine@patapon.info
    just-perfection-desktop@just-perfection
)

if ! command -v gnome-extensions &>/dev/null; then
    echo "gnome-extensions não encontrado: isso é pra uma sessão GNOME." >&2
    exit 1
fi

SHELL_VERSION=$(gnome-shell --version | grep -oE '[0-9]+' | head -1)

# gsettings de extensão: usa o schema que vem dentro dela, então funciona
# mesmo antes de a extensão carregar (antes do relogin).
# Chave que não existe (extensão mudou de versão) só avisa, não aborta.
ext_set() {
    local uuid="$1" schema="$2"; shift 2
    gsettings --schemadir "$EXT_DIR/$uuid/schemas" set "$schema" "$@" 2>/dev/null \
        || echo "  aviso: não deu pra aplicar: $schema $*" >&2
}

if [ -z "$SKIP_DOWNLOAD" ]; then
    echo "== Baixando extensões pro GNOME $SHELL_VERSION =="
    TMP=$(mktemp -d)
    trap 'rm -rf "$TMP"' EXIT
    for uuid in "${EXTENSIONS[@]}"; do
        echo "  -> $uuid"
        curl -fsSL -o "$TMP/$uuid.zip" \
            "https://extensions.gnome.org/download-extension/$uuid.shell-extension.zip?shell_version=$SHELL_VERSION" \
            || { echo "  aviso: $uuid não tem versão pro GNOME $SHELL_VERSION" >&2; continue; }
        gnome-extensions install --force "$TMP/$uuid.zip"
    done
fi

echo "== Ativando extensões =="
gsettings set org.gnome.shell disable-user-extensions false
for uuid in "${EXTENSIONS[@]}"; do
    [ -d "$EXT_DIR/$uuid" ] || continue
    # O enable falha se a extensão ainda não carregou (antes do relogin):
    # aí escreve direto na lista que o GNOME lê ao iniciar.
    if ! gnome-extensions enable "$uuid" 2>/dev/null; then
        cur=$(gsettings get org.gnome.shell enabled-extensions)
        if [[ $cur != *"'$uuid'"* ]]; then
            if [[ $cur == "@as []" || $cur == "[]" ]]; then
                cur="['$uuid']"
            else
                cur="${cur%]}, '$uuid']"
            fi
            gsettings set org.gnome.shell enabled-extensions "$cur"
        fi
    fi
done

echo "== Dhruva: preset macOS, mais transparente, logo do Arch no menu =="
D=(dhruva@narkagni org.gnome.shell.extensions.dhruva)
# Valores do preset "macOS Dock" (src/prefs/Presets.js da extensão)
ext_set "${D[@]}" dock-position 'BOTTOM'
ext_set "${D[@]}" full-width false
ext_set "${D[@]}" icon-alignment 'CENTER'
ext_set "${D[@]}" hybrid-panel-mode false
ext_set "${D[@]}" dynamic-panel false
ext_set "${D[@]}" icon-size 48
ext_set "${D[@]}" icon-spacing 6
ext_set "${D[@]}" dock-height 8
ext_set "${D[@]}" dock-margin 6
ext_set "${D[@]}" dock-padding 0
ext_set "${D[@]}" border-radius 20
ext_set "${D[@]}" dock-theme 'ash'
ext_set "${D[@]}" show-running-indicators true
ext_set "${D[@]}" indicator-style 'dot'
ext_set "${D[@]}" indicator-glow false
ext_set "${D[@]}" hover-zoom true
ext_set "${D[@]}" hover-zoom-style 'fluid'
ext_set "${D[@]}" hover-zoom-factor 1.6
ext_set "${D[@]}" hover-animation false
ext_set "${D[@]}" click-effect 'bounce'
ext_set "${D[@]}" minimize-effect 'magic-lamp'
ext_set "${D[@]}" hide-mode 'intelligent'
ext_set "${D[@]}" show-apps-preview false
ext_set "${D[@]}" peek-effect false
ext_set "${D[@]}" show-grid-button true
ext_set "${D[@]}" grid-button-position 'START'
ext_set "${D[@]}" show-desktop-button false
ext_set "${D[@]}" show-music-pill false
ext_set "${D[@]}" start-menu true
ext_set "${D[@]}" active-preset 'macos'
# Ajustes por cima do preset: vidro mais transparente, borda um pouco
# mais visível pra não sumir no wallpaper
ext_set "${D[@]}" blur-enabled true
ext_set "${D[@]}" background-opacity 40
ext_set "${D[@]}" blur-tint-opacity 0.12
ext_set "${D[@]}" stroke-opacity 25
# Ícone do botão do menu: troque o arquivo por outro .svg/.png pra mudar
GRID_ICON="$HOME/.local/share/icons/dhruva-grid.svg"
if [ ! -e "$GRID_ICON" ] && [ -f /usr/share/pixmaps/archlinux-logo.svg ]; then
    mkdir -p "$(dirname "$GRID_ICON")"
    cp /usr/share/pixmaps/archlinux-logo.svg "$GRID_ICON"
fi
if [ -e "$GRID_ICON" ]; then
    ext_set "${D[@]}" custom-grid-icon "$GRID_ICON"
    ext_set "${D[@]}" custom-grid-icon-scale 80
fi

echo "== Blur my Shell: só o painel de cima =="
B=blur-my-shell@aunetx
BS=org.gnome.shell.extensions.blur-my-shell
ext_set $B $BS.dash-to-dock blur false
ext_set $B $BS.panel blur true
ext_set $B $BS.panel static-blur false
ext_set $B $BS.panel brightness 0.75
ext_set $B $BS.panel sigma 25

echo "== Clipboard Indicator: 30 itens, sem notificação =="
C=(clipboard-indicator@tudmotu.com org.gnome.shell.extensions.clipboard-indicator)
ext_set "${C[@]}" history-size 30
ext_set "${C[@]}" strip-text true
ext_set "${C[@]}" notify-on-cycle false
ext_set "${C[@]}" notify-on-clear false

echo "== Caffeine: sem notificação =="
ext_set caffeine@patapon.info org.gnome.shell.extensions.caffeine show-notifications false

echo "== Modo escuro em tudo (GTK4 pelo color-scheme, GTK3 pelo gtk-theme) =="
# Apps GTK3 (virt-manager, polkit...) ignoram o color-scheme: precisam de um
# tema escuro. O adw-gtk3-dark (pacote adw-gtk-theme) deixa eles iguais aos
# libadwaita; sem ele, cai no Adwaita-dark que já vem no GTK3.
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
if [ -d /usr/share/themes/adw-gtk3-dark ] || [ -d "$HOME/.local/share/themes/adw-gtk3-dark" ]; then
    gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark'
else
    gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
    echo "  dica: instale adw-gtk-theme (Arch) / adw-gtk3-theme (Fedora) e rode de novo"
fi

echo "== Botões de janela estilo macOS (esquerda: fechar, minimizar, maximizar) =="
gsettings set org.gnome.desktop.wm.preferences button-layout 'close,minimize,maximize:appmenu'
# Bolinhas coloridas via CSS do usuário (GTK3 e GTK4/libadwaita). Só cria o
# link se não houver um gtk.css seu lá, pra não sobrescrever nada.
GTK_CSS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/gtk/window-buttons.css"
for v in gtk-3.0 gtk-4.0; do
    dest="$HOME/.config/$v/gtk.css"
    mkdir -p "$(dirname "$dest")"
    if [ -L "$dest" ] || [ ! -e "$dest" ]; then
        ln -sf "$GTK_CSS" "$dest"
    else
        echo "  $dest já existe e não é link: pulei (adicione @import url(\"file://$GTK_CSS\"); nele)"
    fi
done

echo "== Just Perfection: painel de cima mais fino =="
# 0 = altura padrão do GNOME (~32px); o resto da extensão fica no padrão
ext_set just-perfection-desktop@just-perfection org.gnome.shell.extensions.just-perfection panel-size 26

if command -v ptyxis &>/dev/null; then
    echo "== Ptyxis: Catppuccin Mocha, JetBrainsMono Nerd Font =="
    # Paleta como link pro repo (editar aqui vale direto no terminal)
    DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    mkdir -p "$HOME/.local/share/org.gnome.Ptyxis/palettes"
    ln -sf "$DIR/ptyxis/catppuccin-mocha.palette" \
        "$HOME/.local/share/org.gnome.Ptyxis/palettes/catppuccin-mocha.palette"
    gsettings set org.gnome.Ptyxis use-system-font false
    if fc-list | grep -q "JetBrainsMono Nerd Font"; then
        gsettings set org.gnome.Ptyxis font-name 'JetBrainsMono Nerd Font 11'
    fi
    gsettings set org.gnome.Ptyxis interface-style 'dark'
    gsettings set org.gnome.Ptyxis cursor-shape 'ibeam'
    PROFILE=$(gsettings get org.gnome.Ptyxis default-profile-uuid | tr -d "'")
    if [ -n "$PROFILE" ]; then
        PP="org.gnome.Ptyxis.Profile:/org/gnome/Ptyxis/Profiles/$PROFILE/"
        gsettings set "$PP" palette 'catppuccin-mocha'
        gsettings set "$PP" opacity 0.95
        gsettings set "$PP" label 'Catppuccin Mocha'
    fi
fi

# Terminal padrão do GNOME (Ctrl+Alt+T, "abrir no terminal" do Nautilus):
# Ghostty (config em common/ghostty) se tiver, senão o Ptyxis
if command -v ghostty &>/dev/null; then
    echo com.mitchellh.ghostty.desktop >"$HOME/.config/xdg-terminals.list"
elif command -v ptyxis &>/dev/null; then
    echo org.gnome.Ptyxis.desktop >"$HOME/.config/xdg-terminals.list"
fi

echo ""
echo "Pronto! Se alguma extensão foi instalada agora, saia e entre de novo"
echo "na sessão (no Wayland o GNOME só carrega extensões novas no login)."
