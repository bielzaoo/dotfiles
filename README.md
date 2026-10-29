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
- `session/` — `~/.config/session/autostart.sh`, agnóstico de compositor (waybar, mako, `vicinae server`, wallpaper). Trocar de WM = reescrever `hypr/`, o resto fica. No login ele regera o wallpaper (`fundo`) e passa pro `awww`; sem PNG, cai na cor sólida do fundo da paleta.
- `vicinae/` — launcher + histórico do clipboard (`WIN+R`, `WIN+SHIFT+V`), tema `vga`. O Vicinae não está nos repos: instalado à mão em `~/.local/opt/vicinae`.
- `kitty/` — substitui o `common/kitty` (ver `common.skip`).
- `swayimg/`, `zathura/` — visualizador de imagens e leitor de PDF padrão. Os dois só guardam o que muda do default e carregam um `tema-atual` (cores e fonte da paleta) que o `repinta` gera: `swayimg/init.lua` faz `dofile` do `tema-atual.lua`, o `zathurarc` faz `include tema-atual`. Valem no próximo arquivo aberto. No zathura, `Ctrl+R` deixa a página escura nas cores da paleta.
- `bin/` — `fonte`, `cor` e `espaco`: um script só que troca o preset ativo; `tema` (`WIN+T`) escolhe eixo e preset no Vicinae, incluindo o `fundo`, e `tema <eixo>` pula direto pro preset (`fonte spleen`, `cor fosforo`, `espaco colado`; sem argumento lista). `pacotes-salva` regrava `pacotes.txt` e `servicos.txt` a partir do sistema atual. `pastas` troca a cor das pastas (`pastas grey`; sem argumento lista): gera o tema `Papirus-Pastas` no usuário, herdando do Papirus-Dark e só trocando os links de pasta, sem root nem `papirus-folders`. `fundo` gera o wallpaper (`fundo-atual.png`) com dados reais da máquina, na paleta e fonte do kitty, via ImageMagick + pango. Modos: `fundo boot` (default: POST de BIOS + log do systemd com DMI, CPU, RAM, NVMe, LUKS, btrfs, Secure Boot, kernel e services rodando, e os protection rings do x86 no canto, com o ring 0 no verde do `ok`), `fundo panic` (o "Attempted to kill init!" com kernel, hardware e systemd reais) e `fundo liso` (cor sólida). O modo escolhido fica em `fundo-modo-atual` e vale até trocar; sem argumento lista os modos (como `cor`/`fonte`/`espaco`) e `fundo regera` regera no modo gravado, que é o que o `repinta` (então `cor`/`fonte` repintam o wallpaper também) e o login chamam. **Trocar de wallpaper:** duplo clique no wallpaper (fora de janela e da waybar) abre o seletor `tema fundo`, ou `WIN+T` → `fundo`. O seletor tem **preview**: a lista são os PNGs de `~/.cache/fundo/` (`fundo previas`, um por modo, na paleta atual) e o quick look do `vicinae dmenu` mostra a imagem ao lado. O `repinta` regera esse cache em segundo plano a cada `cor`/`fonte`, então o seletor abre na hora. O duplo clique é um bind `non_consuming` em `mouse:272` no `binds.lua`, checado no próprio Lua (cursor fora de janela visível e da área reservada da waybar), sem processo por clique; `CLIQUES` e `JANELA_MS` ajustam (3 = clique triplo). Em paleta monocromática (verde do `ok` colado no texto, como a `fosforo`) o `OK` vira bloco invertido.
- `pacotes.txt` — `pacman -Qqen` (explícitos dos repos): `sudo pacman -S --needed - < pacotes.txt`.
- `servicos.txt` — units habilitadas, `system <unit>` / `user <unit>`.
- `manuais.md` — o que vem de fora do pacman (Vicinae, fontes Cozette/Spleen).

- `system/` — espelho de `/` (não é pacote de stow, o `install.sh` pula): config de sistema que é decisão minha (nftables, greetd, pacman, reflector, mkinitcpio, snapper, zram, hook `04-uki-backup`).
- `bootstrap.sh` — de um Arch recém-instalado ao sistema montado, idempotente, rodando como usuário (sudo onde precisa): pacotes → `system/` (diff + backup `.bak-bootstrap`; regenera UKI/recarrega nftables se mudarem) → `install.sh main` → hardening (playbook no brain, `~/brain`) → serviços (`enable` sem `--now`) → aviso do `manuais.md`. `./bootstrap.sh -n` = ensaio seco (playbook em `--check --diff`).

Mudou pacote ou serviço? Rode `pacotes-salva`, confira o diff e commite junto. Mudou algo em `/etc` que está em `system/`? Copie pra cá; o `bootstrap.sh -n` acusa drift.

**Captura de tela** (`captura`, foto e vídeo num lugar só): a seleção é esperta, com as janelas visíveis viram caixas do `slurp` e o `-o` põe os monitores, então clicar numa janela pega a janela, clicar no fundo pega a tela inteira e arrastar pega uma área (Esc cancela; cores da paleta). `Print` = foto com seleção, `SHIFT+Print` = tela inteira direto (as duas vão pra `~/Pictures/Capturas` e pro clipboard), `WIN+Print` = grava, `WIN+SHIFT+Print` = grava com o áudio do sistema (monitor da saída padrão); o mesmo atalho para. Vídeo pelo `wf-recorder` em H.264 na GPU (VA-API) em `~/Videos/Gravacoes`, com largura e altura arredondadas pra par. Enquanto grava, a waybar mostra `● rec` (custom/captura, SIGRTMIN+8), e clicar nele para. Clicar na notificação abre o arquivo. Transmitir/gravar com cenas: OBS (pelo portal do Hyprland).

**Apps padrão** (aplicados pelo `setup.sh` com `xdg-mime`, porque o Firefox reescreve o `mimeapps.list` e um symlink não sobreviveria): imagem no swayimg, PDF/EPUB/XPS no zathura, vídeo e áudio no mpv, pasta no Nautilus (o yazi segue no `WIN+F`), web no Firefox. Os tipos saem do `MimeType=` de cada `.desktop`; o zathura-pdf-mupdf também reivindica imagem, então fica só com o que não é imagem. O `setup.sh` também roda o `xdg-user-dirs-update` (Desktop, Pictures, Music, Videos, Templates, Public, Projects).

Os presets ativos são symlinks `*-atual` (estado local, fora do git). O `setup.sh` cria os defaults (Cozette, `vga`, `justo`) quando faltam.

**Modo escuro fora do `repinta`:** o `setup.sh` grava `color-scheme=prefer-dark` e `gtk-theme=Adwaita-dark` no gsettings. O portal repassa isso pro Firefox, o Chromium, o Electron (Bitwarden) e os apps GTK. Fica no dconf, fora do git, por isso o `setup.sh` reaplica. Ele também roda `pastas grey` (ícones Papirus, pastas cinza no lugar do azul do Adwaita). O Bitwarden não segue o sistema (o Electron enxerga o escuro, o app não): tema fixado em Configurações → Aparência → Escuro, fica no perfil dele, fora do git.

**Arquivos:** `WIN+F` abre o **yazi** no kitty puro (prévia de imagem sem passthrough do tmux; prévias via `ffmpeg`, `poppler`, `imagemagick`, `resvg`, `7zip`), `WIN+SHIFT+F` abre o **Nautilus** (arrastar pro navegador, montar pendrive/celular com `gvfs`/`gvfs-mtp`). O seletor de arquivos dos apps vem do `xdg-desktop-portal-gtk`, não do file manager.

**Navegadores:** Firefox no dia a dia, Chromium só pros web apps (ver a seção dos web apps). O Firefox leva o [Betterfox](https://github.com/yokoffing/Betterfox): `firefox/` linka `betterfox.js` (o `user.js` upstream, intocado, versão fixa) e `overrides.js` (meus ajustes) em `~/.config/mozilla/firefox/betterfox/`, e o `setup.sh` junta os dois no `user.js` do perfil padrão (lido do `installs.ini`), porque a pasta do perfil tem nome aleatório. Pra atualizar, troque o `betterfox.js` pelo `user.js` da release nova e rode o `setup.sh`.

**Interface do Firefox:** `firefox/.../chrome/userChrome.css` (linkado como `chrome/` do perfil pelo `setup.sh`) pinta abas, URL bar e painéis com a paleta e a fonte do kitty, que vêm de um `tema-atual.css` gerado pelo `repinta`. Também deixa a URL bar reta e minimalista (ícones extras só com o mouse em cima; o cadeado fica sempre) e põe URL e abas numa linha só a partir de 900px de largura. Abaixo disso volta pras duas linhas. O Firefox só relê o CSS quando reinicia, então depois de um `cor`/`fonte` é preciso reabrir. Os nomes de variável e de elemento são os do Firefox 158; se algo parar de pintar depois de um update, é por aí.

**Favoritos no Firefox:** `Ctrl+D` grava na hora (`showForNewBookmarks=false` no `overrides.js`), com só um aviso rápido. Com o painel de edição ligado (padrão do Firefox), a página fica pendente até o "Salvar" e o Esc descarta ela, mas não as pastas criadas no caminho: era por isso que a barra aparecia com pasta nova e sem a página. Pra escolher pasta/nome, `Ctrl+D` de novo na página já salva. A estrela fica sempre visível na URL bar e verde (`--uc-ok`, o `color10` que o `repinta` exporta) quando a página está salva. Barra de favoritos só na nova aba; `Ctrl+Shift+B` mostra/esconde até reabrir, `Ctrl+B` abre os favoritos na lateral, `Ctrl+Shift+O` o gerenciador.

`common.skip` lista os pacotes de `common/` que o perfil substitui (`kitty`, `tmux`, `nvim`) ou não usa (`zsh`, `starship`); do `common/` o `main` só pega `ssh-agent` e `webapps`.

**Binds de janela/app:** `WIN+W` fecha a janela (no lugar do `WIN+C` do exemplo do Hyprland), `WIN+Enter`/`WIN+SHIFT+Enter` terminal com/sem tmux, `WIN+F`/`WIN+SHIFT+F` yazi/Nautilus.

**Terminal:** `bash/` (`.bashrc` com prompt ANSI, fzf e zoxide no lugar do `cd`) e `tmux/` (`~/.config/tmux/tmux.conf`, mesmos keybinds do `common/tmux`, tema só com `colour0..15`, então segue o `cor`; o verde (`colour10`/`colour2`) é o destaque: sessão, prefix aceso, número da janela atual, borda do painel ativo e branch, com amarelo pra copy mode e janela com atividade). `WIN+Enter` abre o kitty dentro do tmux (`tmux-entra`), `WIN+SHIFT+Enter` sem. `sessao` (ou prefix `f`) escolhe uma pasta do zoxide e entra na sessão dela. O `atalhos` (`WIN+K`) lista Hyprland, tmux (binds com `-N`) e qualquer linha `#: tecla | descrição` do `tmux.conf`, `kitty.conf` e `.bashrc`.

**Editor:** `nvim/` é o starter do LazyVim, com os Extras declarados no `lua/config/lazy.lua` (não só no `lazyvim.json`), pra ficarem revisáveis no git: Python, YAML, JSON, Markdown, TOML, Docker e git, mais `yanky`, `mini-surround`, `inc-rename`, `mini-hipatterns` e `util.dot`. Linguagem nova = uma linha a mais. Os LSPs vêm do Mason no primeiro arquivo aberto (por isso `unzip`, `nodejs`, `npm` e `tree-sitter-cli` no `pacotes.txt`). Versões travadas no `lazy-lock.json`, sem checagem automática de update: atualizar é `:Lazy update` e commitar o lock.

**Tema do editor:** o `repinta` gera `lua/tema-atual.lua` (paleta base16 a partir do kitty, sintaxe nas cores claras 8-15) e o `lua/plugins/tema.lua` monta o colorscheme com o `mini.base16`, plano como o resto (um fundo só, borda 1px no `color8`; statusline como a waybar, só o modo em bloco invertido). Trocou o `cor`, o `repinta` chama `Repinta()` em todo nvim aberto pelo socket (`$XDG_RUNTIME_DIR/nvim.<pid>.0`). Mudou o `tema.lua`? Aí precisa reabrir o nvim.

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

`common/webapps/.local/bin/webapp` transforma um site num app: janela própria do Chrome (sem abas nem barra de endereço), ícone próprio e item próprio no menu e na dock. Usa o `google-chrome` se existir, senão o `chromium` (o caso do `main`, onde o Chromium é só pros web apps e o navegador do dia a dia é outro). `WEBAPP_BROWSER=...` força um.

```bash
webapp add "WhatsApp" https://web.whatsapp.com/           # ícone oficial, baixado do próprio site (padrão)
webapp add "Foo" https://foo.example/ ~/icone.png          # ou um nome do tema / caminho de .png/.svg
webapp rm "WhatsApp"
webapp list
webapp sync     # cria todos os da lista ~/.config/webapps/list (versionada aqui)
```

Por que não o "Instalar app" do Chrome: no Wayland a janela de um `--app=URL` ignora o `--class`, e o Chrome dá a ela o app_id `chrome-<host>_<caminho>-Default` (ex.: `chrome-web.whatsapp.com__-Default`). Se não existir um `.desktop` com esse nome, o KDE não sabe de quem é a janela e agrupa com o Chrome, com o ícone do Chrome, como se fosse uma aba. O script cria o `.desktop` exatamente com esse nome (testado no Chrome 156). Os web apps usam o perfil `Default` do Chrome, então os logins são os mesmos do navegador.

Pra adicionar um de vez, ponha uma linha no `common/webapps/.config/webapps/list` e rode `webapp sync`. O ícone padrão é `site`, o oficial: baixa o `/apple-touch-icon.png` do próprio site (o ícone de quando você "instala" o site no celular; quase todo site tem, e ele passa até quando o site bloqueia o `curl` na página), confere se é PNG mesmo e guarda em `~/.local/share/icons/webapps/`.

## LazyVim (extras)

Isto é dos perfis antigos: o `main` tem o LazyVim completo em `profiles/main/nvim/` (ver a seção do main). Nos outros, o Neovim versionado é o `common/nvim`. O LazyVim eu instalo à mão, então ele não fica aqui, só os ajustes em `extras/lazyvim/`, no mesmo caminho do `~/.config/nvim`. Depois de instalar o LazyVim:

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
