#!/usr/bin/env bash
# Visual moderno pro KDE Plasma 6: tema escuro neutro (Breeze Dark), ícones
# Papirus, janelas com botões estilo mac à esquerda (Klassy), barra no topo
# + dock flutuante embaixo, e animações (magic lamp, janelas gelatinosas,
# cubo de áreas de trabalho, maximizar/encaixar suave).
#
# Não usa stow de propósito: o KDE reescreve kwinrc/kdeglobals/etc. no
# lugar, o que quebraria os symlinks. Aqui tudo é aplicado com
# kwriteconfig6/D-Bus, então é idempotente e pode rodar de novo.
#
# Uso: bash ~/dotfiles/profiles/kde/setup.sh
#
# Variáveis opcionais:
#   SKIP_PACKAGES=1  não instala nada (só aplica as configs)
#   SKIP_PANELS=1    não recria os painéis (preserva widgets que você
#                    adicionou na mão depois)
#
# Instalar pacotes precisa de sudo — rode num terminal interativo.
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -z "$SKIP_PACKAGES" ]; then
    echo "== Instalando pacotes =="
    sudo pacman -S --needed papirus-icon-theme
    # klassy: decoração de janela (botões semáforo estilo mac)
    # kwin-effects-geometry-change: anima maximizar/encaixar janelas
    yay -S --needed klassy kwin-effects-geometry-change
fi

echo "== Tema global: Breeze Dark =="
plasma-apply-lookandfeel -a org.kde.breezedark.desktop

if [ -d /usr/share/icons/Papirus-Dark ]; then
    echo "== Ícones: Papirus-Dark =="
    /usr/lib/plasma-changeicons Papirus-Dark
fi

echo "== Ícone do menu: logo do Arch em branco =="
install -Dm644 "$DIR/icons/archlinux-logo-white.svg" \
    "$HOME/.local/share/icons/hicolor/scalable/apps/archlinux-logo-white.svg"

if command -v klassy-settings &>/dev/null; then
    echo "== Decoração: Klassy com botões estilo mac =="
    kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key library org.kde.klassy
    kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key theme Klassy
    # "Eaten Fruits" é o preset do Klassy no estilo mac (bolinhas
    # vermelho/amarelo/verde, ícone só no hover, cantos arredondados).
    klassy-settings -w "Eaten Fruits"
    # Fechar, minimizar, maximizar à esquerda; nada à direita.
    kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key ButtonsOnLeft XIA
    kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key ButtonsOnRight ""
else
    echo "klassy não instalado; mantendo a decoração atual." >&2
fi

echo "== Efeitos do KWin =="
# Magic lamp e squash são alternativas pro minimizar; só um pode ficar ligado.
kwriteconfig6 --file kwinrc --group Plugins --key magiclampEnabled true
kwriteconfig6 --file kwinrc --group Plugins --key squashEnabled false
kwriteconfig6 --file kwinrc --group Plugins --key wobblywindowsEnabled true
kwriteconfig6 --file kwinrc --group Plugins --key cubeEnabled true
kwriteconfig6 --file kwinrc --group Plugins --key kwin4_effect_geometry_changeEnabled true

echo "== Áreas de trabalho: 4 (Meta+C abre o cubo) =="
count=$(qdbus6 org.kde.KWin /VirtualDesktopManager org.kde.KWin.VirtualDesktopManager.count)
while [ "$count" -lt 4 ]; do
    qdbus6 org.kde.KWin /VirtualDesktopManager org.kde.KWin.VirtualDesktopManager.createDesktop "$count" "Área $((count + 1))"
    count=$((count + 1))
done

qdbus6 org.kde.KWin /KWin reconfigure
# reconfigure não liga/desliga efeitos; na sessão atual isso é via D-Bus.
qdbus6 org.kde.KWin /Effects org.kde.kwin.Effects.unloadEffect squash >/dev/null
for effect in magiclamp wobblywindows cube kwin4_effect_geometry_change; do
    qdbus6 org.kde.KWin /Effects org.kde.kwin.Effects.loadEffect "$effect" >/dev/null ||
        echo "efeito $effect não carregou (instalado?)" >&2
done

if [ -z "$SKIP_PANELS" ]; then
    echo "== Painéis: barra no topo + dock =="
    qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "$(cat "$DIR/panels.js")"
fi

echo ""
echo "Pronto! Se algum efeito não aparecer de cara, faça logout/login."
