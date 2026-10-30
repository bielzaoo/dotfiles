#!/usr/bin/env bash
# Bootstrap do perfil main: de um Arch recém-instalado (archinstall) até o
# sistema montado. Idempotente: rodar de novo só aplica o que mudou.
# Roda como o seu usuário (não root); usa sudo onde precisa.
#   ./bootstrap.sh       aplica
#   ./bootstrap.sh -n    só mostra o que mudaria (diff de /etc, pacotes faltando)
# Fora daqui (ver manuais.md e o doc de restore no brain): layout @snapshots,
# wg0, chaves SSH, Vicinae e fontes.
set -euo pipefail

dir=$(cd "$(dirname "$0")" && pwd)
raiz=$(cd "$dir/../.." && pwd)
brain=${BRAIN:-$HOME/brain}
seco=0
[ "${1:-}" = "-n" ] && seco=1

passo() { printf '\n==> %s\n' "$*"; }
[ "$(id -u)" -ne 0 ] || { echo "rode como seu usuário, não root" >&2; exit 1; }

passo "Pacotes (pacotes.txt)"
faltando=$(comm -23 <(sort "$dir/pacotes.txt") <(pacman -Qqe | sort))
if [ -z "$faltando" ]; then
    echo "todos instalados"
elif [ $seco -eq 1 ]; then
    echo "faltando:"; echo "$faltando"
else
    sudo pacman -S --needed - < "$dir/pacotes.txt"
fi

passo "Arquivos de sistema (system/)"
mudou=()
while IFS= read -r -d '' src; do
    rel=${src#"$dir/system"}
    case "$rel" in
        /usr/local/bin/*)     modo=755 ;;
        /etc/snapper/configs/*) modo=640 ;;
        *)                    modo=644 ;;
    esac
    if sudo cmp -s "$src" "$rel" 2>/dev/null; then
        continue
    fi
    mudou+=("$rel")
    sudo diff -u --label "$rel (atual)" --label "$rel (repo)" "$rel" "$src" 2>/dev/null || true
    [ -e "$rel" ] || echo "novo: $rel"
    if [ $seco -eq 0 ]; then
        [ -e "$rel" ] && sudo cp -a "$rel" "$rel.bak-bootstrap"
        sudo install -D -m "$modo" -o root -g root "$src" "$rel"
    fi
done < <(find "$dir/system" -type f -print0 | sort -z)
[ ${#mudou[@]} -eq 0 ] && echo "nada mudou"

if [ $seco -eq 0 ]; then
    uki=0
    for f in "${mudou[@]}"; do
        case "$f" in
            # O tema do plymouth vai dentro do initramfs: mudou, regera também
            /etc/mkinitcpio.conf | /etc/plymouth/* | /usr/share/plymouth/*) uki=1 ;;
            /etc/locale.gen)      passo "locale.gen mudou: gerando locales"; sudo locale-gen ;;
            /etc/nftables.conf)   passo "nftables.conf mudou: recarregando"; sudo nft -c -f "$f" && sudo nft -f "$f" ;;
        esac
    done
    if [ $uki -eq 1 ]; then passo "initramfs mudou (mkinitcpio/plymouth): regenerando UKIs"; sudo mkinitcpio -P; fi
fi

passo "Dotfiles (install.sh main)"
# install.sh usa caminhos relativos ao repo
[ $seco -eq 1 ] && echo "pulado no -n" || (cd "$raiz" && ./install.sh main)

passo "Hardening (playbook no brain)"
pb="$brain/artifacts/infra/workstation/hardening"
if [ ! -f "$pb/playbook.yml" ]; then
    echo "brain não encontrado em $brain: rode o hardening depois de clonar o brain"
else
    ansible-galaxy collection install -r "$pb/requirements.yml" >/dev/null
    chk=(); [ $seco -eq 1 ] && chk=(--check --diff)
    (cd "$pb" && ansible-playbook -i inventory.ini playbook.yml -K "${chk[@]}")
fi

passo "Serviços (servicos.txt)"
# enable sem --now: o greetd subindo no meio do bootstrap derrubaria a TTY.
# Template sem instância (getty@.service) não habilita assim; vem ligado de fábrica.
while read -r escopo unit; do
    [[ "$unit" == *@.* ]] && continue
    if [ "$escopo" = system ]; then
        systemctl is-enabled -q "$unit" 2>/dev/null && continue
        echo "habilitando $unit"
        [ $seco -eq 1 ] || sudo systemctl enable "$unit"
    else
        systemctl --user is-enabled -q "$unit" 2>/dev/null && continue
        echo "habilitando (user) $unit"
        [ $seco -eq 1 ] || systemctl --user enable "$unit"
    fi
done < "$dir/servicos.txt"

passo "Conferir"
mountpoint -q /.snapshots || echo "AVISO: /.snapshots não montado; o snapper precisa do @snapshots flat (brain: workstation/snapshots/README.md)"
echo "Fora do pacman, na mão: $dir/manuais.md"
[ $seco -eq 1 ] || echo "Pronto. Reinicie pra greetd, zram e serviços subirem."
