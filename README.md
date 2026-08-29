# dotfiles

Estrutura: **common** (compartilhado entre qualquer perfil) + **profiles** (específico de cada shell/WM escolhido) + **archive** (histórico, não usado ativamente).

```
.
├── common/
│   ├── nvim/           → LazyVim + tema crimson
│   ├── kitty/.config/kitty
│   ├── tmux/             → config + tema Catppuccin Mocha (ver seção abaixo)
│   ├── ssh-agent/        → ssh-agent via systemd --user (ver seção abaixo)
│   └── qemu/             → QEMU/KVM + libvirt + firewall (ver seção abaixo)
├── profiles/
│   ├── classic/         → setup atual (estável, uso diário)
│   │   ├── hypr/.config/hypr     → Hyprland em Lua, hypridle, hyprlock, hyprpaper
│   │   └── waybar/.config/waybar → bar com Bluetooth, powermenu, etc
│   └── quickshell/       → projeto futuro (Qt6/QML), vazio por enquanto
└── archive/
    ├── rofi/            → não usado mais (substituído por wofi)
    └── nwg-bar/         → não usado mais
```

## Instalação

```bash
git clone https://github.com/bielzaoo/dotfiles ~/dotfiles
cd ~/dotfiles
./install.sh classic
```

Isso aplica os pacotes de `common/` + o perfil escolhido via symlinks (GNU Stow).

## Trocar de perfil

```bash
# desfaz os symlinks do perfil atual (ajuste "classic" pro que estiver ativo)
for pkg in profiles/classic/*/; do stow -D -d profiles/classic -t "$HOME" "$(basename "$pkg")"; done

# aplica o novo
./install.sh quickshell
```

## Tmux

- `common/tmux/.tmux.conf` — prefix, binds, mouse etc. Pode mudar à vontade.
- `common/tmux/.tmux/themes/catppuccin-mocha.conf` — só o esquema de cores (bordas, status bar com separadores slant em Nerd Font, mode, clock), importado via `source-file` no `.tmux.conf`. Auto-contido: dá pra copiar só esse arquivo pra `~/.tmux/themes/` em outra máquina e importar em qualquer `.tmux.conf`, sem arrastar keybinds.

## SSH agent

`./install.sh` já cuida disso automaticamente, mas dá pra rodar só essa parte em qualquer sistema, sem o resto dos dotfiles (não precisa nem de `stow`):

```bash
bash ~/dotfiles/common/ssh-agent/install.sh
```

O que ele faz (idempotente, pode rodar de novo sem problema):

- `common/ssh-agent/.local/bin/ssh-agent-setup` habilita o `ssh-agent.socket` do systemd `--user` (`systemctl --user enable --now ssh-agent.socket`). Isso faz o agente subir sozinho por socket-activation, sem precisar iniciar nada na mão depois de uma reinstalação.
- `common/ssh-agent/.local/bin/ssh-agent-init` é adicionado ao final do `~/.bashrc` (entre os marcadores `# >>> dotfiles ssh-agent >>>`/`<<<`) e roda em toda shell interativa: aponta `SSH_AUTH_SOCK` pro socket do systemd e, se o agente ainda estiver vazio (primeira shell depois de ligar o PC), carrega as chaves privadas de `~/.ssh` com `ssh-add` (pede a passphrase uma vez só; as shells seguintes reusam o mesmo agente).

## QEMU/KVM

Setup completo de virtualização — instala e libera a rede das VMs no firewall de uma vez, sem precisar do resto dos dotfiles:

```bash
bash ~/dotfiles/common/qemu/install.sh
```

O que ele faz (idempotente, precisa de sudo):

- Instala `qemu-desktop` + `libvirt` + `virt-manager` (+ `virt-viewer`, `dnsmasq`, `edk2-ovmf` pra UEFI, `swtpm` pra TPM).
- Habilita e inicia o `libvirtd.service`.
- Adiciona seu usuário aos grupos `libvirt` e `kvm` (precisa logout/login pra valer).
- Ativa e marca como autostart a rede NAT padrão do libvirt (`virbr0`).
- Libera `virbr0` no UFW (`ufw allow in on virbr0` + `ufw route allow in on virbr0`) — é essa liberação que resolve o problema clássico de VM sem internet até mexer no firewall na mão.

## Por que essa estrutura

- Editar algo compartilhado (Neovim, tmux) uma vez só afeta os dois perfis — sem merge entre branches.
- `classic` e `quickshell` nunca coexistem ao mesmo tempo (stacks incompatíveis: GTK+wofi+waybar vs Qt6+Quickshell), então faz sentido escolher um no momento da instalação em vez de manter os dois ativos.
- `archive/` preserva histórico (rofi, nwg-bar) sem misturar com o que está de fato em uso.
