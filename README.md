# dotfiles

Estrutura: **common** (compartilhado entre qualquer perfil) + **profiles** (específico de cada shell/WM escolhido) + **archive** (histórico, não usado ativamente).

```
.
├── common/
│   ├── nvim/           → LazyVim + tema crimson
│   ├── kitty/.config/kitty → JetBrains Mono, rastro no cursor, abas estilizadas, tema Vantablack (igual ao Neovim) ou Catppuccin black
│   ├── tmux/             → keybinds do Omarchy + tema Vantablack (layout do tokyo-night) (ver seção abaixo)
│   ├── zsh/              → ls vira eza, cd vira zoxide (ver seção abaixo)
│   ├── starship/         → prompt com logo do Arch, fundo preto
│   ├── ssh-agent/        → ssh-agent via systemd --user (ver seção abaixo)
│   ├── qemu/             → QEMU/KVM + libvirt + firewall (ver seção abaixo)
│   ├── wireguard/        → sobe o túnel WireGuard no boot (ver seção abaixo)
│   ├── plymouth/         → tela gráfica de boot + senha do disco (ver seção abaixo)
│   └── webapps/          → sites como apps (WhatsApp etc.) com ícone e janela próprios (ver seção abaixo)
├── profiles/
│   ├── main/            → **perfil principal**: Arch + Hyprland (Lua modular), Vicinae, rodízio fonte/cor/espaço (ver seção abaixo)
│   ├── classic/         → setup anterior (Hyprland + wofi), não usado mais
│   │   ├── hypr/.config/hypr     → Hyprland em Lua, hypridle, hyprlock, hyprpaper
│   │   └── waybar/.config/waybar → bar com Bluetooth, powermenu, etc
│   ├── kde/             → KDE Plasma 6: tema, botões estilo mac, dock, animações (ver seção abaixo)
│   ├── fedora-gnome/    → Fedora + GNOME: visual escuro leve, só pacotes oficiais (ver seção abaixo)
│   ├── fedora-kde/      → Fedora + KDE Plasma: barra fina + dock, Konsole no visual do kitty (ver seção abaixo)
│   └── quickshell/       → projeto futuro (Qt6/QML), vazio por enquanto
├── extras/
│   ├── lazyvim/          → ajustes pro LazyVim instalado à mão (ver seção abaixo)
│   └── ssh/              → modelo do ~/.ssh/config: uma chave por host do GitHub (ver seção abaixo)
└── archive/
    ├── rofi/            → não usado mais (substituído por wofi)
    └── nwg-bar/         → não usado mais
```

## Instalação

```bash
git clone https://github.com/bielzaoo/dotfiles ~/dotfiles
cd ~/dotfiles
./install.sh main
```

Isso aplica os pacotes de `common/` + o perfil escolhido via symlinks (GNU Stow).

Pasta de `common/` com `install.sh` é **instalador**, não pacote de stow: o `install.sh` raiz roda o `ssh-agent` e o `zsh` no fim; `plymouth`, `qemu` e `wireguard` mexem no sistema e são na mão (seções abaixo). `profiles/<perfil>/common.skip` lista o que o perfil não quer de `common/`, um nome por linha, instaladores inclusos.

## Trocar de perfil

```bash
# desfaz os symlinks do perfil atual (ajuste "classic" pro que estiver ativo)
for pkg in profiles/classic/*/; do stow -D -d profiles/classic -t "$HOME" "$(basename "$pkg")"; done

# aplica o novo
./install.sh quickshell
```

## Tmux

- `common/tmux/.tmux.conf` — prefix, binds, mouse etc. Pode mudar à vontade. Keybinds no esquema do Omarchy (tabela abaixo).
- `common/tmux/.tmux/themes/vantablack.conf` — tema ativo: mesmo layout do tokyo-night-black, nas cores do [vantablack.nvim](https://github.com/bjarneo/vantablack.nvim) (tons de cinza, fundo `#0d0d0d`). O kitty usa o `vantablack.conf` com o mesmo fundo, pra não aparecer moldura em volta do Neovim. Lá a interface (abas, bordas, cursor) também é cinza, mas as 16 cores ANSI são coloridas e apagadas, pra eza/ls/git continuarem diferenciando pasta (azul), executável (verde), link (ciano) etc. O Neovim não usa essas cores e continua todo cinza.
- `common/tmux/.tmux/themes/tokyo-night-black.conf` — layout do [tokyo-night-tmux](https://github.com/janoamaral/tokyo-night-tmux) (sessão com ícone que muda no prefix, janelas com ícone, pasta, branch e data ❬ hora) nas cores do Catppuccin. É tmux puro, sem os scripts do plugin nem TPM.
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

## main (perfil principal)

Arch + Hyprland montado do zero (plano e checklist no brain, `artifacts/infra/workstation/`).

- `hypr/` — único pacote específico do compositor. `hyprland.lua` só faz `require` dos módulos.
- `session/` — `~/.config/session/autostart.sh`, agnóstico de compositor (waybar, mako, `vicinae server`, wallpaper). Trocar de WM = reescrever `hypr/`, o resto fica.
- `vicinae/` — launcher + histórico do clipboard (`WIN+R`, `WIN+SHIFT+V`), tema `vga`. O Vicinae não está nos repos: instalado à mão em `~/.local/opt/vicinae`.
- `kitty/` — substitui o `common/kitty` (ver `common.skip`).
- `bin/` — `fonte`, `cor` e `espaco`: um script só que troca o preset ativo (`fonte spleen`, `cor fosforo`, `espaco colado`; sem argumento lista).

Os presets ativos são symlinks `*-atual` (estado local, fora do git). O `setup.sh` cria os defaults (Cozette, `vga`, `justo`) quando faltam.

`common.skip` lista os pacotes de `common/` que o perfil substitui (`kitty`) ou não usa (`nvim`, `tmux`, `zsh`, `starship`); do `common/` o `main` só pega `ssh-agent` e `webapps`.

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

- `common/ssh-agent/.local/bin/ssh-agent-setup` habilita o `ssh-agent.socket` do systemd `--user` (`systemctl --user enable --now ssh-agent.socket`). Isso faz o agente subir sozinho por socket-activation, sem precisar iniciar nada na mão depois de uma reinstalação. No GNOME ele também mascara o `gcr-ssh-agent` e grava `~/.config/environment.d/ssh-agent.conf`, pra sessão gráfica usar o mesmo agente das shells (senão apps abertos pelo menu, como o Obsidian com obsidian-git, caem num agente vazio e pedem a senha da chave). Vale depois de relogar.
- `common/ssh-agent/.local/bin/ssh-agent-init` é adicionado ao final do `~/.bashrc` e do `~/.zshrc` (entre os marcadores `# >>> dotfiles ssh-agent >>>`/`<<<`) e roda em toda shell interativa: aponta `SSH_AUTH_SOCK` pro socket do systemd e, se o agente ainda estiver vazio (primeira shell depois de ligar o PC), carrega as chaves privadas de `~/.ssh` com `ssh-add` (pede a passphrase uma vez só; as shells seguintes reusam o mesmo agente).

## SSH config (várias chaves no GitHub)

`extras/ssh/config.example` é o modelo do `~/.ssh/config`. Fica em `extras/` (e não vira symlink) porque cada máquina tem as próprias chaves:

```bash
install -m 600 ~/dotfiles/extras/ssh/config.example ~/.ssh/config
```

Resolve o **"Repository not found"** que aparece com mais de uma chave carregada. O ssh oferece ao GitHub todas as chaves do agente, uma por vez, e o GitHub aceita a primeira que for de **qualquer** conta sua. Se essa conta não tem acesso ao repositório, a resposta é "not found" (e não "sem permissão"). O `IdentitiesOnly yes` com um `IdentityFile` por host faz o ssh oferecer só a chave certa:

- `github.com` → `~/.ssh/github` (a chave principal, conta `bielzaoo`).
- Outra conta/chave: descomente o bloco `github-trabalho`, aponte pra chave e use o apelido no lugar do host: `git clone git@github-trabalho:usuario/repo.git` (num repo já clonado: `git remote set-url origin git@github-trabalho:usuario/repo.git`).
- `AddKeysToAgent yes`: a chave entra no agente sozinha na primeira vez que for usada.

Pra testar: `ssh -T git@github.com` tem que responder `Hi bielzaoo!`, e `ssh -G github.com | grep identit` mostra qual chave vai ser usada.

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
- **Painéis** (`profiles/kde/panels.js`): barra fina no topo (menu, áreas de trabalho, relógio no centro, bandeja) + dock flutuante centralizada embaixo, sempre translúcida, que some quando uma janela encosta nela. **Recria os painéis do zero**: use `SKIP_PANELS=1` pra reaplicar o resto sem perder widgets que você adicionou na mão.
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
- **Apps Flatpak no escuro**: Flatpak roda isolado e não enxerga o `adw-gtk3` do dnf, então o setup instala a extensão `org.gtk.Gtk3theme.adw-gtk3-dark` do Flathub e força `GTK_THEME` com `flatpak override --user`. Apps Electron como o Obsidian têm o próprio tema (Settings → Appearance).
- **Ptyxis** (terminal padrão do GNOME) com o visual do kitty: paleta `ptyxis/.local/share/org.gnome.Ptyxis/palettes/vantablack.palette` (mesmas cores do `vantablack.conf`) e JetBrains Mono 11. Padding, rastro do cursor e abas powerline continuam só no kitty.
- **Ícones da Nerd Font (opcional)**: `INSTALL_NERD_SYMBOLS=1 bash .../setup.sh` roda o `nerd-symbols.sh`, que baixa só a `NerdFontsSymbolsOnly` da release oficial no GitHub (versão fixa, conferida pelo `SHA-256.txt` da release) pra `~/.local/share/fonts`. É a única coisa fora dos repositórios do Fedora, por isso fica desligada por padrão. O `fontconfig/.../50-nerd-symbols.conf` põe os símbolos logo *depois* da JetBrains Mono (`<accept>`, e não o `<prefer>` do conf oficial), então o texto não muda e os ícones não caem em outra fonte do sistema.
- **Shell de login**: troca pra zsh com `chsh` (o Ptyxis e o tmux usam a shell de login).
- **ssh-agent**: roda o `common/ssh-agent/install.sh` (ver seção do ssh-agent), que também desliga o `gcr-ssh-agent` do GNOME.
- **Prompt no lugar do starship** (`zsh/.config/zsh/prompt.zsh`): o starship não está nos repositórios do Fedora, então o prompt é feito em zsh puro minimalista numa linha só (raio, seta que fica vermelha quando o comando falha e o nome da pasta, mais git, venv e tempo do último comando quando houver). Ele é montado sem `prompt_subst` e escapa o nome da branch, então um repositório clonado com uma branch tipo `$(comando)` não executa nada.

## Fedora + KDE Plasma

Mesmo espírito do perfil do GNOME (escuro, leve, só repositórios oficiais do Fedora), sem as animações e o Klassy do perfil `kde` do Arch.

```bash
bash ~/dotfiles/profiles/fedora-kde/setup.sh     # não use ./install.sh (é feito pro Arch)
```

O que o `profiles/fedora-kde/setup.sh` aplica (idempotente, via `kwriteconfig6` e D-Bus, pelo mesmo motivo do perfil `kde`):

- **Visual**: tema global Fedora Dark (Breeze Dark com o wallpaper do Fedora), ícones Papirus-Dark, `breeze-gtk` pros apps GTK nativos e janelas novas no centro. Estilo do Plasma **Breeze Vidro**, gerado pelo script em `~/.local/share/plasma/desktoptheme/breeze-vidro` a partir do SVG do Breeze: só o fundo translúcido dos painéis muda (35% em vez de 85%, ajuste com `PANEL_OPACITY=0.2`, por exemplo) e o blur do plasmashell é desligado, senão o wallpaper borrado atrás da dock parece um fundo sólido; o resto é o Breeze.
- **Painéis** (`profiles/fedora-kde/panels.js`): barra fina no topo (26 px: menu, relógio com dia da semana no centro, bandeja) + dock flutuante centralizada embaixo, sempre translúcida, que some quando uma janela encosta (Dolphin, navegador, Konsole, Discover, Configurações). **Recria os painéis do zero**: use `SKIP_PANELS=1` pra reaplicar o resto sem perder widgets que você adicionou na mão.
- **Konsole** com o visual do kitty: esquema `konsole/.local/share/konsole/Vantablack.colorscheme` (mesmas cores do `vantablack.conf`, é o único symlink), perfil `Vantablack` como padrão, JetBrains Mono 11, abre o zsh direto e sem barra de menu (`Ctrl+Shift+M` mostra de novo). O perfil é gerado pelo script, e não versionado, porque o Konsole reescreve o arquivo quando você mexe nas configurações dele.
- **Web apps**: linka o `common/webapps` e roda `webapp sync` (ver seção dos web apps).
- **O resto é igual ao do GNOME**: kitty, tmux, zsh com o prompt e o `zshrc` do `profiles/fedora-gnome`, apps Flatpak no `adw-gtk3-dark`, shell de login em zsh e ssh-agent único (o Plasma do Fedora já respeita o `SSH_AUTH_SOCK` do `environment.d`).
- **Ícones da Nerd Font**: o Konsole, como o Ptyxis, não tem os símbolos embutidos, então sem eles os ícones do prompt viram quadradinhos. `INSTALL_NERD_SYMBOLS=1 bash .../setup.sh` roda o mesmo `profiles/fedora-gnome/nerd-symbols.sh` (ver seção do GNOME).

## Web apps (sites como apps)

`common/webapps/.local/bin/webapp` transforma um site num app: janela própria do Chrome (sem abas nem barra de endereço), ícone próprio e item próprio no menu e na dock.

```bash
webapp add "WhatsApp" https://web.whatsapp.com/ whatsapp   # ícone do tema ou caminho de um .png/.svg
webapp add "Claude" https://claude.ai/ site                # baixa o ícone do próprio site
webapp rm "WhatsApp"
webapp list
webapp sync     # cria todos os da lista ~/.config/webapps/list (versionada aqui)
```

Por que não o "Instalar app" do Chrome: no Wayland a janela de um `--app=URL` ignora o `--class`, e o Chrome dá a ela o app_id `chrome-<host>_<caminho>-Default` (ex.: `chrome-web.whatsapp.com__-Default`). Se não existir um `.desktop` com esse nome, o KDE não sabe de quem é a janela e agrupa com o Chrome, com o ícone do Chrome, como se fosse uma aba. O script cria o `.desktop` exatamente com esse nome (testado no Chrome 156). Os web apps usam o perfil `Default` do Chrome, então os logins são os mesmos do navegador.

Pra adicionar um de vez, ponha uma linha no `common/webapps/.config/webapps/list` e rode `webapp sync`. Ícones do Papirus: `find /usr/share/icons/Papirus/64x64/apps -iname '*nome*'`. Se o Papirus não tiver, `site` baixa o `/apple-touch-icon.png` do próprio site (o ícone de quando você "instala" o site no celular; quase todo site tem, e ele passa até quando o site bloqueia o `curl` na página), confere se é PNG mesmo e guarda em `~/.local/share/icons/webapps/`.

## LazyVim (extras)

O Neovim versionado é o `common/nvim`. O LazyVim eu instalo à mão, então ele não fica aqui, só os ajustes em `extras/lazyvim/`, no mesmo caminho do `~/.config/nvim`. Depois de instalar o LazyVim:

```bash
cp -r ~/dotfiles/extras/lazyvim/lua ~/.config/nvim/
```

- `lua/plugins/colorscheme.lua`: [vantablack.nvim](https://github.com/bjarneo/vantablack.nvim), fundo `#0d0d0d`, igual ao `vantablack.conf` do kitty e do tmux. (O Catppuccin com fundo preto que tinha aqui antes está no histórico do git.)

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
