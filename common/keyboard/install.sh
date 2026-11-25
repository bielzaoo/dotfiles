#!/usr/bin/env bash
# Tecla "/?" do ThinkPad brasileiro como tecla normal (ver o .hwdb)
set -e
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ "$EUID" -eq 0 ] || { echo "rode com sudo" >&2; exit 1; }
install -Dm644 "$DIR/90-thinkpad-abnt2.hwdb" /etc/udev/hwdb.d/90-thinkpad-abnt2.hwdb
systemd-hwdb update
udevadm trigger --sysname-match="event*"
echo "Pronto: a tecla do Ctrl direito agora é a \"/?\" do ABNT2."
