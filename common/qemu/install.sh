#!/usr/bin/env bash
# Instala QEMU/KVM + libvirt + virt-manager e libera a rede NAT das VMs
# (virbr0) no firewall — resolve o problema de toda VM nova não ter
# internet até liberar a interface na mão.
#
# Funciona no Arch (pacman + UFW ou nftables) e no Fedora (dnf + firewalld). No
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
elif command -v nft &>/dev/null && [ -f /etc/nftables.conf ]; then
    # nftables puro: NÃO editamos o firewall daqui (no profile main ele vem do
    # system/etc/nftables.conf via bootstrap.sh). Só conferimos. Um "policy
    # drop" em input/forward sem regra pra virbr0 vence o accept das tabelas do
    # libvirt: VM sem DHCP ("instalador não acha a rede") e sem internet.
    echo "== Conferindo a rede das VMs (virbr0) no nftables =="
    if grep -q 'virbr0' /etc/nftables.conf; then
        echo "  /etc/nftables.conf já libera a virbr0"
    else
        echo "  AVISO: /etc/nftables.conf não menciona virbr0. Se input/forward" >&2
        echo "  forem 'policy drop', as VMs ficam sem rede. Precisa de:" >&2
        echo '    input:   iifname "virbr0" udp dport { 53, 67 } accept' >&2
        echo '             iifname "virbr0" tcp dport 53 accept' >&2
        echo '    forward: iifname "virbr0" accept' >&2
        echo '             oifname "virbr0" ct state established,related accept' >&2
    fi
    if grep -q '^[[:space:]]*flush ruleset' /etc/nftables.conf; then
        echo "  AVISO: 'flush ruleset' no nftables.conf apaga as tabelas do libvirt a" >&2
        echo "  cada reload (NAT das VMs some). Recrie só a sua tabela:" >&2
        echo "    table inet filter / delete table inet filter / table inet filter { ... }" >&2
    fi
else
    echo "Nem firewalld, nem ufw, nem nftables encontrados; pulando regras de firewall (ajuste na mão se usar outro firewall)." >&2
fi

echo ""
echo "Pronto! Faça logout/login (ou reinicie) pra pegar os grupos libvirt/kvm"
echo "na sua sessão, e abra o virt-manager pra criar sua primeira VM."
