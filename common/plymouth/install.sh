#!/usr/bin/env bash
# Tela gráfica no boot com Plymouth, inclusive o pedido de senha do LUKS
# (no lugar do prompt em texto). Tema bgrt: logo do fabricante (o da
# Lenovo, vindo da BIOS) + campo de senha.
#
# Feito pro boot desta máquina: GRUB -> UKI gerado pelo mkinitcpio
# (/boot/EFI/Linux/arch-linux.efi), parâmetros do kernel em
# /etc/kernel/cmdline (embutidos no UKI; /etc/default/grub não é usado),
# e hook `encrypt`, que já pede a senha pelo Plymouth quando ele está
# rodando. O layout do teclado da senha vem do XKBLAYOUT do
# /etc/vconsole.conf.
#
# Rede de segurança: na primeira execução copia o UKI atual pra
# /boot/EFI/Linux/arch-linux-sem-plymouth.efi. O GRUB lista os UKIs dessa
# pasta sozinho, então se o boot novo travar, é só escolher a outra
# entrada "Arch Linux" no menu do GRUB. Também guarda cópias do
# mkinitcpio.conf e do cmdline com o sufixo .sem-plymouth.
#
# Esse backup costuma ficar em PRIMEIRO no menu (e o GRUB inicia o
# primeiro por padrão). Então, depois de bootar com o Plymouth uma vez,
# rode o script de novo: vendo `splash` no boot atual, ele move o backup
# pra /boot/EFI/backup/, fora do menu (sem apagar).
#
# Idempotente. Uso: bash ~/dotfiles/common/plymouth/install.sh
# Precisa de sudo — roda num terminal interativo.
set -e

UKI=/boot/EFI/Linux/arch-linux.efi
BACKUP=/boot/EFI/Linux/arch-linux-sem-plymouth.efi
PARKED=/boot/EFI/backup/arch-linux-sem-plymouth.efi

echo "== Instalando o Plymouth =="
sudo pacman -S --needed plymouth

if grep -qw splash /proc/cmdline; then
    # Já bootou com o Plymouth: o backup não precisa mais ficar no menu.
    if sudo test -f "$BACKUP"; then
        echo "== Boot com Plymouth confirmado: tirando o backup do menu do GRUB =="
        sudo mkdir -p "$(dirname "$PARKED")"
        sudo mv "$BACKUP" "$PARKED"
    fi
elif ! sudo test -f "$BACKUP" && ! sudo test -f "$PARKED"; then
    echo "== Backup do boot atual (UKI, mkinitcpio.conf, cmdline) =="
    sudo cp "$UKI" "$BACKUP"
    sudo cp /etc/mkinitcpio.conf /etc/mkinitcpio.conf.sem-plymouth
    sudo cp /etc/kernel/cmdline /etc/kernel/cmdline.sem-plymouth
fi

echo "== Hook plymouth antes do encrypt =="
if ! grep -qE '^HOOKS=.*\bplymouth\b' /etc/mkinitcpio.conf; then
    sudo sed -i -E '/^HOOKS=/ s/\bencrypt\b/plymouth encrypt/' /etc/mkinitcpio.conf
fi
grep -E '^HOOKS=' /etc/mkinitcpio.conf

echo "== Parâmetros do kernel: quiet splash =="
for param in quiet splash; do
    if ! grep -qw "$param" /etc/kernel/cmdline; then
        sudo sed -i "1 s/\$/ $param/" /etc/kernel/cmdline
    fi
done
cat /etc/kernel/cmdline

echo "== Tema: bgrt =="
sudo plymouth-set-default-theme bgrt

echo "== Gerando o UKI de novo =="
sudo mkinitcpio -P

echo ""
if grep -qw splash /proc/cmdline; then
    echo "Pronto! O menu do GRUB volta a iniciar direto o boot com Plymouth."
else
    echo "Pronto! Reinicie pra ver. O backup pode vir primeiro no menu do GRUB:"
    echo "escolha a outra entrada \"Arch Linux\". Depois de bootar com o Plymouth,"
    echo "rode este script de novo pra tirar o backup do menu."
fi
