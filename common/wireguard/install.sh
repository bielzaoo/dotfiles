#!/usr/bin/env bash
# Sobe o túnel WireGuard automaticamente no boot via systemd
# (wg-quick@<iface>.service), em vez de rodar `sudo wg-quick up wg0`
# na mão toda vez que liga o PC.
#
# O .conf NÃO fica no repo (tem chave privada) — ele precisa já existir
# em /etc/wireguard/<iface>.conf antes de rodar isso.
#
# Idempotente: pode rodar de novo sem problema.
#
# Uso: bash common/wireguard/install.sh          (interface wg0)
#      bash common/wireguard/install.sh wg1      (outra interface)
#
# Precisa de sudo — roda em terminal interativo pra poder digitar a senha.
set -e

IFACE="${1:-wg0}"
UNIT="wg-quick@${IFACE}.service"

if ! sudo test -f "/etc/wireguard/${IFACE}.conf"; then
    echo "/etc/wireguard/${IFACE}.conf não existe; coloque a config lá primeiro." >&2
    exit 1
fi

echo "== Instalando wireguard-tools =="
sudo pacman -S --needed wireguard-tools

# Se o túnel foi levantado na mão (wg-quick up), o systemd não sabe dele e
# o start falha com "wg0 already exists" — derruba antes pra ele assumir.
if ip link show "$IFACE" &>/dev/null && ! systemctl is-active --quiet "$UNIT"; then
    echo "== Derrubando $IFACE levantado manualmente =="
    sudo wg-quick down "$IFACE"
fi

echo "== Habilitando $UNIT (sobe no boot) =="
sudo systemctl enable --now "$UNIT"

echo ""
systemctl --no-pager status "$UNIT" | head -5
echo ""
echo "Pronto! O $IFACE vai subir sozinho no boot."
echo "Controle manual: sudo systemctl {stop,start,restart} $UNIT"
