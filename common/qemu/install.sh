#!/usr/bin/env bash
# Instala QEMU/KVM + libvirt + virt-manager e libera a rede NAT das VMs
# (virbr0) no UFW — resolve o problema de toda VM nova não ter internet
# até liberar a interface na mão.
#
# Idempotente: pode rodar de novo (outra máquina, ou pra reaplicar as
# regras do firewall) sem duplicar nada.
#
# Uso: bash common/qemu/install.sh      (a partir da raiz do repo)
#      bash ~/dotfiles/common/qemu/install.sh   (de qualquer lugar)
#
# Precisa de sudo (instala pacotes, mexe em grupos e no firewall) —
# roda em terminal interativo pra poder digitar a senha.
set -e

PACKAGES=(qemu-desktop libvirt virt-manager virt-viewer dnsmasq edk2-ovmf swtpm)

echo "== Instalando QEMU/KVM + libvirt + virt-manager =="
sudo pacman -S --needed "${PACKAGES[@]}"

echo "== Habilitando libvirtd =="
sudo systemctl enable --now libvirtd.service

echo "== Adicionando $USER aos grupos libvirt/kvm =="
sudo usermod -aG libvirt,kvm "$USER"

echo "== Ativando a rede NAT padrão do libvirt (virbr0) =="
sudo virsh net-start default 2>/dev/null || true
sudo virsh net-autostart default

if command -v ufw &>/dev/null; then
    echo "== Liberando a rede das VMs (virbr0) no UFW =="
    sudo ufw allow in on virbr0 comment 'libvirt: DHCP/DNS das VMs (virbr0)'
    sudo ufw route allow in on virbr0 comment 'libvirt: NAT das VMs (virbr0) pra internet'
    sudo ufw reload
else
    echo "ufw não encontrado; pulando regras de firewall (ajuste na mão se usar outro firewall)." >&2
fi

echo ""
echo "Pronto! Faça logout/login (ou reinicie) pra pegar os grupos libvirt/kvm"
echo "na sua sessão, e abra o virt-manager pra criar sua primeira VM."
