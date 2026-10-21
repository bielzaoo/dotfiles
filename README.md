# dotfiles

Estrutura: **common** (compartilhado entre qualquer perfil) + **profiles** (específico de cada shell/WM escolhido) + **archive** (histórico, não usado ativamente).

```
.
├── common/
│   ├── nvim/           → LazyVim + tema crimson
│   ├── kitty/.config/kitty → JetBrains Mono, rastro no cursor, abas estilizadas, tema Catppuccin black
│   ├── tmux/             → keybinds do Omarchy + tema tokyo-night nas cores do kitty (ver seção abaixo)
│   ├── zsh/              → ls vira eza, cd vira zoxide (ver seção abaixo)
│   ├── starship/         → prompt com logo do Arch, fundo preto
│   ├── ssh-agent/        → ssh-agent via systemd --user (ver seção abaixo)
│   ├── qemu/             → QEMU/KVM + libvirt + firewall (ver seção abaixo)
│   ├── wireguard/        → sobe o túnel WireGuard no boot (ver seção abaixo)
│   └── plymouth/         → tela gráfica de boot + senha do disco (ver seção abaixo)
├── profiles/
│   ├── classic/         → setup atual (estável, uso diário)
│   │   ├── hypr/.config/hypr     → Hyprland em Lua, hypridle, hyprlock, hyprpaper
│   │   └── waybar/.config/waybar → bar com Bluetooth, powermenu, etc
│   ├── kde/             → KDE Plasma 6: tema, botões estilo mac, dock, animações (ver seção abaixo)
│   ├── fedora-gnome/    → Fedora + GNOME: visual escuro leve, só pacotes oficiais (ver seção abaixo)
│   └── quickshell/       → projeto futuro (Qt6/QML), vazio por enquanto
├── extras/
│   └── lazyvim/          → ajustes pro LazyVim instalado à mão (ver seção abaixo)
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

- `common/tmux/.tmux.conf` — prefix, binds, mouse etc. Pode mudar à vontade. Keybinds no esquema do Omarchy (tabela abaixo).
- `common/tmux/.tmux/themes/tokyo-night-black.conf` — tema ativo: layout do [tokyo-night-tmux](https://github.com/janoamaral/tokyo-night-tmux) (sessão com ícone que muda no prefix, janelas com ícone, pasta, branch e data ❬ hora) nas cores do kitty. É tmux puro, sem os scripts do plugin nem TPM.
- `common/tmux/.tmux/themes/catppuccin-black.conf` — mesmas cores do Mocha, mas com fundo preto puro pra combinar com o kitty.
- `common/tmux/.tmux/themes/catppuccin-mocha.conf` — Catppuccin Mocha original.

Pra trocar de tema, mude o `source-file` no fim do `.tmux.conf`. Os temas têm só o esquema de cores e são auto-contidos: dá pra copiar só o arquivo pra `~/.tmux/themes/` em outra máquina e importar em qualquer `.tmux.conf`, sem arrastar keybinds.

| Tecla | O quê |
|---|---|
| `Ctrl+Space` (ou `Ctrl+a`) | prefix |
| prefix `h` / `v` | divide: um embaixo do outro / lado a lado |
| prefix `x` | fecha o painel |
| `Ctrl+Alt+setas` | muda de painel (no GNOME, use prefix + setas; ver abaixo) |
| `Ctrl+Alt+Shift+setas` | redimensiona o painel |
| prefix `c` / `k` / `r` | nova janela / fecha janela / renomeia janela |
| `Alt+1..9` | vai pra janela N |
| `Alt+←/→` | janela anterior / próxima |
| `Alt+Shift+←/→` | move a janela pra esquerda / direita |
| prefix `C` / `K` / `R` | nova sessão / fecha sessão / renomeia sessão |
| `Alt+↑/↓` (ou prefix `P` / `N`) | sessão anterior / próxima |
| prefix `[`, depois `v` e `y` | copy mode estilo vi, `y` copia pro clipboard |
| prefix `q` | recarrega a config |

No GNOME, `Ctrl+Alt+setas` já trocam de área de trabalho e chegam antes do tmux. O prefix + setas (padrão do tmux) faz o mesmo.

## zsh: eza e zoxide

```bash
bash ~/dotfiles/common/zsh/install.sh
```

Linka `common/zsh/.config/zsh/modern-cli.zsh` e adiciona um `source` no fim do `~/.zshrc` (entre os marcadores `# >>> dotfiles modern-cli >>>`/`<<<`):

- `ls` vira `eza` com ícones e pastas primeiro; `ll`/`la`/`l` com detalhes e status do git, `lt` em árvore.
- `cd` vira o `zoxide`: ele aprende as pastas que você visita, então `cd dotf` pula pra `~/dotfiles` de qualquer lugar. `cdi` abre a busca interativa (fzf).

O prompt (`common/starship/.config/starship.toml`) segue a mesma paleta Catppuccin sobre preto, com o logo do Arch; o `~/.zshrc` já tem o `eval "$(starship init zsh)"`.

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
- **Animações**: magic lamp ao minimizar, janelas gelatinosas (wobbly), maximizar/encaixar suave (`kwin-effects-geometry-change`, AUR) cubo 3D com 4 áreas de trabalho (**Meta+C** abre o cubo), Alt+Tab em carrossel 3D (Cover Switch) e troca de área deslizando só as janelas, com o wallpaper parado.
- **Visão geral**: canto superior esquerdo (ou Meta+W) abre a visão geral, canto superior direito (ou Meta+G) abre a grade de áreas de trabalho, e **Meta+Tab** alterna entre as duas (vale depois de deslogar/logar).

Não usa stow porque o KDE reescreve `kwinrc`/`kdeglobals`/etc. no lugar e quebraria os symlinks. Tudo é aplicado com `kwriteconfig6` e D-Bus. Pra ajustar os detalhes dos botões depois: Configurações do sistema → Decorações de janelas → Klassy.

## Fedora + GNOME

Perfil pro Fedora Workstation: visual escuro, moderno e **leve**, sempre de olho na segurança. Tudo vem dos repositórios oficiais do Fedora (`dnf install --repo=fedora --repo=updates`, ou seja, pacotes assinados e nada de repositório de terceiros), sem COPR, sem `curl | sh` e sem temas baixados de site.

```bash
bash ~/dotfiles/profiles/fedora-gnome/setup.sh     # não use ./install.sh (é feito pro Arch)
```

O que o `profiles/fedora-gnome/setup.sh` aplica (idempotente, via `gsettings`):

- **Visual**: modo escuro, `adw-gtk3-dark` (deixa os apps GTK3 iguais aos libadwaita), ícones Papirus-Dark, dia da semana no relógio e % da bateria.
- **Janelas**: botões minimizar/maximizar/fechar, e janelas novas abrem no centro.
- **Extensões** (só duas, porque extensão roda dentro do gnome-shell sem sandbox): AppIndicator (ícones na bandeja) e Dash to Dock (dock embaixo que some quando uma janela encosta, sem lixeira/discos). Elas aparecem depois de deslogar e logar de novo.
- **tmux**: config e temas do `common/tmux` (keybinds do Omarchy, tema tokyo-night-black).
- **kitty**: config do `common/kitty`. Como a Nerd Font não está nos repositórios do Fedora, o setup cria um `~/.config/kitty/local.conf` (fora do git) com a JetBrains Mono oficial. Os ícones continuam aparecendo porque o kitty já vem com os símbolos da Nerd Font embutidos.
- **zsh sem oh-my-zsh**: o `~/.zshrc` é criado a partir do `profiles/fedora-gnome/zshrc` (só se ainda não existir), com os plugins `zsh-autosuggestions` e `zsh-syntax-highlighting` empacotados pelo Fedora, mais o eza/zoxide do `common/zsh`.
- **Prompt no lugar do starship** (`zsh/.config/zsh/prompt.zsh`): o starship não está nos repositórios do Fedora, então o prompt é feito em zsh puro minimalista numa linha só (raio, seta que fica vermelha quando o comando falha e o nome da pasta, mais git, venv e tempo do último comando quando houver). Ele é montado sem `prompt_subst` e escapa o nome da branch, então um repositório clonado com uma branch tipo `$(comando)` não executa nada.

## LazyVim (extras)

O Neovim versionado é o `common/nvim`. O LazyVim eu instalo à mão, então ele não fica aqui, só os ajustes em `extras/lazyvim/`, no mesmo caminho do `~/.config/nvim`. Depois de instalar o LazyVim:

```bash
cp -r ~/dotfiles/extras/lazyvim/lua ~/.config/nvim/
```

- `lua/plugins/colorscheme.lua`: Catppuccin Mocha com fundo preto, igual ao kitty/tmux/starship. Usa `catppuccin-mocha` (e não `catppuccin`) porque o Neovim já vem com um `colors/catppuccin.vim` embutido que ganharia do plugin no startup.

`extras/` fica fora de `common/` e `profiles/` de propósito: não é pacote do stow, então nada ali vira symlink na home.

## Plymouth (tela de boot e senha do disco)

Troca o pedido de senha do LUKS em modo texto por uma tela gráfica (tema `bgrt`: logo da Lenovo vindo da BIOS + campo de senha), que segue até o login:

```bash
bash ~/dotfiles/common/plymouth/install.sh
```

Feito pro boot desta máquina: GRUB → UKI (`/boot/EFI/Linux/arch-linux.efi`) gerado pelo `mkinitcpio`. Por isso o `quiet splash` vai em `/etc/kernel/cmdline` (que é embutido no UKI), e não no `/etc/default/grub`. O script instala o `plymouth`, põe o hook `plymouth` antes do `encrypt`, escolhe o tema e regera o UKI. A senha usa o layout do `XKBLAYOUT` do `/etc/vconsole.conf` (hoje `br`).

**Backup e primeiro boot:** na primeira execução o script copia o UKI antigo pra `/boot/EFI/Linux/arch-linux-sem-plymouth.efi`, e o GRUB lista ele sozinho. Ele costuma vir **primeiro** no menu (e é o que o GRUB inicia por padrão), então no primeiro boot escolha a **outra** entrada "Arch Linux". Funcionou? Rode o script de novo: vendo `splash` no boot atual, ele move o backup pra `/boot/EFI/backup/`, fora do menu.

**Se um dia precisar do backup:** no menu do GRUB aperte `c` e rode `chainloader /EFI/backup/arch-linux-sem-plymouth.efi` e depois `boot`. Pra desfazer de vez, copie de volta `/etc/mkinitcpio.conf.sem-plymouth` e `/etc/kernel/cmdline.sem-plymouth` e rode `sudo mkinitcpio -P`.

## Por que essa estrutura

- Editar algo compartilhado (Neovim, tmux) uma vez só afeta os dois perfis — sem merge entre branches.
- `classic` e `quickshell` nunca coexistem ao mesmo tempo (stacks incompatíveis: GTK+wofi+waybar vs Qt6+Quickshell), então faz sentido escolher um no momento da instalação em vez de manter os dois ativos.
- `archive/` preserva histórico (rofi, nwg-bar) sem misturar com o que está de fato em uso.
