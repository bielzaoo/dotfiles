#!/usr/bin/env bash
# Instala QEMU/KVM + libvirt + virt-manager e libera a rede NAT das VMs
# (virbr0) no firewall — resolve o problema de toda VM nova não ter
# internet até liberar a interface na mão.
#
# Funciona no Arch (pacman + UFW) e no Fedora (dnf + firewalld). No
# Fedora o libvirt já integra com o firewalld (põe o virbr0 na zona
# "libvirt"), então aqui só confere se isso aconteceu e corrige se não.
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

if command -v pacman &>/dev/null; then
    echo "== Instalando QEMU/KVM + libvirt + virt-manager (pacman) =="
    sudo pacman -S --needed qemu-desktop libvirt virt-manager virt-viewer dnsmasq edk2-ovmf swtpm

    echo "== Habilitando libvirtd =="
    sudo systemctl enable --now libvirtd.service
elif command -v dnf &>/dev/null; then
    echo "== Instalando QEMU/KVM + libvirt + virt-manager (dnf) =="
    sudo dnf install -y qemu-kvm libvirt-daemon-kvm libvirt-daemon-config-network \
        virt-install virt-manager virt-viewer edk2-ovmf swtpm

    # O Fedora usa os daemons modulares do libvirt (virtqemud, virtnetworkd...)
    # com socket-activation, no lugar do libvirtd monolítico.
    echo "== Habilitando os daemons modulares do libvirt =="
    for drv in qemu interface network nodedev nwfilter secret storage; do
        sudo systemctl enable --now "virt${drv}d.socket" "virt${drv}d-ro.socket" "virt${drv}d-admin.socket"
    done
else
    echo "Gerenciador de pacotes não suportado (nem pacman nem dnf)." >&2
    exit 1
fi

echo "== Adicionando $USER aos grupos libvirt/kvm =="
sudo usermod -aG libvirt,kvm "$USER"

echo "== Ativando a rede NAT padrão do libvirt (virbr0) =="
sudo virsh net-start default 2>/dev/null || true
sudo virsh net-autostart default

if systemctl is-active --quiet firewalld; then
    echo "== Conferindo a rede das VMs (virbr0) no firewalld =="
    zone=$(sudo firewall-cmd --get-zone-of-interface=virbr0 2>/dev/null || true)
    if [ "$zone" != "libvirt" ]; then
        echo "  virbr0 estava na zona '${zone:-nenhuma}'; movendo pra 'libvirt'"
        sudo firewall-cmd --permanent --zone=libvirt --change-interface=virbr0
        sudo firewall-cmd --reload
    fi
    echo "  virbr0 na zona libvirt (DHCP/DNS/NAT das VMs liberados)"
elif command -v ufw &>/dev/null; then
    echo "== Liberando a rede das VMs (virbr0) no UFW =="
    sudo ufw allow in on virbr0 comment 'libvirt: DHCP/DNS das VMs (virbr0)'
    sudo ufw route allow in on virbr0 comment 'libvirt: NAT das VMs (virbr0) pra internet'
    sudo ufw reload
else
    echo "Nem firewalld nem ufw encontrados; pulando regras de firewall (ajuste na mão se usar outro firewall)." >&2
fi

echo ""
echo "Pronto! Faça logout/login (ou reinicie) pra pegar os grupos libvirt/kvm"
echo "na sua sessão, e abra o virt-manager pra criar sua primeira VM."
