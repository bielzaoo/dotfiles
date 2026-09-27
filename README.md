# dotfiles

Estrutura: **common** (compartilhado entre qualquer perfil) + **profiles** (específico de cada shell/WM escolhido) + **archive** (histórico, não usado ativamente).

```
.
├── common/
│   ├── nvim/           → LazyVim + tema crimson
│   ├── kitty/.config/kitty
│   ├── tmux/             → config + tema Catppuccin Mocha (ver seção abaixo)
│   ├── ssh-agent/        → ssh-agent via systemd --user (ver seção abaixo)
│   ├── qemu/             → QEMU/KVM + libvirt + firewall (ver seção abaixo)
│   └── wireguard/        → sobe o túnel WireGuard no boot (ver seção abaixo)
├── profiles/
│   ├── classic/         → setup atual (estável, uso diário)
│   │   ├── hypr/.config/hypr     → Hyprland em Lua, hypridle, hyprlock, hyprpaper
│   │   └── waybar/.config/waybar → bar com Bluetooth, powermenu, etc
│   ├── kde/             → KDE Plasma 6: tema, botões estilo mac, dock, animações (ver seção abaixo)
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
- `common/ssh-agent/.local/bin/ssh-agent-init` é adicionado ao final do `~/.bashrc` e do `~/.zshrc` (entre os marcadores `# >>> dotfiles ssh-agent >>>`/`<<<`) e roda em toda shell interativa: aponta `SSH_AUTH_SOCK` pro socket do systemd e, se o agente ainda estiver vazio (primeira shell depois de ligar o PC), carrega as chaves privadas de `~/.ssh` com `ssh-add` (pede a passphrase uma vez só; as shells seguintes reusam o mesmo agente).

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

## WireGuard

Sobe o túnel WireGuard automaticamente no boot (via `wg-quick@wg0.service`), sem precisar de `sudo wg-quick up wg0` toda vez:

```bash
bash ~/dotfiles/common/wireguard/install.sh        # wg0 (padrão)
bash ~/dotfiles/common/wireguard/install.sh wg1    # outra interface
```

A config (`/etc/wireguard/wg0.conf`) não fica no repo porque tem chave privada — ela precisa já existir lá. Se o túnel estiver levantado na mão, o script derruba e deixa o systemd assumir. Depois disso, controle com `sudo systemctl {stop,start,restart} wg-quick@wg0`.

## KDE Plasma

Perfil pro KDE Plasma 6 (Wayland): visual escuro neutro e moderno, sem imitar o mac, mas com os botões de janela estilo mac.

```bash
./install.sh kde                          # tudo (stow do common + setup do KDE)
bash ~/dotfiles/profiles/kde/setup.sh     # só a parte do KDE
```

O que o `profiles/kde/setup.sh` aplica (idempotente):

- **Tema**: global Breeze Dark + ícones Papirus-Dark.
- **Janelas**: decoração [Klassy](https://github.com/paulmcauley/klassy) (AUR) com o preset "Eaten Fruits": botões redondos vermelho/amarelo/verde **à esquerda** (fechar, minimizar, maximizar), ícone só no hover, cantos arredondados e barra de título translúcida com blur.
- **Painéis** (`profiles/kde/panels.js`): barra fina no topo (menu, áreas de trabalho, relógio no centro, bandeja) + dock flutuante centralizada embaixo, que some quando uma janela encosta nela. **Recria os painéis do zero**: use `SKIP_PANELS=1` pra reaplicar o resto sem perder widgets que você adicionou na mão.
- **Animações**: magic lamp ao minimizar, janelas gelatinosas (wobbly), maximizar/encaixar suave (`kwin-effects-geometry-change`, AUR) e cubo 3D com 4 áreas de trabalho (**Meta+C** abre o cubo).

Não usa stow porque o KDE reescreve `kwinrc`/`kdeglobals`/etc. no lugar e quebraria os symlinks. Tudo é aplicado com `kwriteconfig6` e D-Bus. Pra ajustar os detalhes dos botões depois: Configurações do sistema → Decorações de janelas → Klassy.

## Por que essa estrutura

- Editar algo compartilhado (Neovim, tmux) uma vez só afeta os dois perfis — sem merge entre branches.
- `classic` e `quickshell` nunca coexistem ao mesmo tempo (stacks incompatíveis: GTK+wofi+waybar vs Qt6+Quickshell), então faz sentido escolher um no momento da instalação em vez de manter os dois ativos.
- `archive/` preserva histórico (rofi, nwg-bar) sem misturar com o que está de fato em uso.
