# CLAUDE.md — dotfiles (bielzaoo)

Este arquivo dá contexto ao Claude Code sobre o setup e as convenções deste repositório. Leia antes de propor mudanças.

## Visão geral do sistema

- Arch Linux + Hyprland (config em **Lua nativo**, não `.conf` legado)
- Filosofia: TUI-first, segurança em primeiro lugar (LUKS2, Btrfs+Snapper, UFW), preferência por peças curadas em vez de distros/stacks "tudo em um"
- Modularidade é uma preferência forte, mas **não é regra absoluta** — o dono do repo aceita trocar por algo mais "monolítico" (como Quickshell) quando o ganho visual/funcional compensa

## Estrutura do repo

```
dotfiles/
├── common/              # nvim, tmux — usado em qualquer profile
├── profiles/
│   ├── classic/hypr/    # stack hypr+waybar completo (LEGADO, em migração)
│   │   └── .config/hypr/   # ⚠️ NÃO é symlinkado via Stow ainda — ver "Pendências"
│   └── quickshell/       # projeto Quickshell (ATIVO — ver abaixo)
│       ├── .config/quickshell/   # symlinkado via Stow, funcionando corretamente
│       ├── .config/kitty/        # tema ciano (kitty.conf + theme.conf), symlinkado
│       └── .config/starship.toml # tema ciano, symlinkado
└── archive/              # rofi, nwg-bar (descontinuados)
```

`kitty` e `starship.toml` são **profile-specific** (moraram em `common/` antes, mas foram movidos pra dentro de `profiles/quickshell` porque o tema de cores é amarrado ao profile visual em uso — se o profile `classic` for reativado um dia, ele precisa do seu próprio tema, não do ciano).

Deploy via **GNU Stow**. Comando padrão: `cd ~/dotfiles/profiles && stow -t ~ <pacote>`.

## Projeto ativo: migração waybar/wofi/mako → Quickshell

**Status: bar, notificações, OSD (volume/brilho) e launcher de apps (substitui `wofi --show drun`) migrados e validados. Migração concluída.**

Motivação: Hyprland "puro" ficava visualmente engessado; Quickshell (Qt6/QML) permite animações e widgets mais ricos. Decisão consciente de abrir mão de parte da modularidade em troca disso.

### Paleta do projeto Quickshell

**Diferente** da paleta Vanta Black + Crimson + Rose que o setup usava antes (waybar/hyprland legado — só relevante se o profile `classic` for reativado):
- Base: preto (`#000000` / `#0a0a0a` alt)
- Accent: azul neon (`#00f0ff`, dim `#0090a0`)
- Texto: `#e0e0e0` primário, `#808080` muted
- Estados: danger `#ff3b3b`, success `#00ff9c`

Definido em `Colors.qml` (singleton) e `Fonts.qml` (singleton, fonte JetBrainsMono Nerd Font). Essa paleta **não é mais exclusiva do Quickshell**: também é usada em `profiles/quickshell/.config/kitty/theme.conf` (terminal), `profiles/quickshell/.config/starship.toml` (prompt) e nas cores de borda/sombra do Hyprland (`modules/appearance.lua`, `col.active_border`/`col.inactive_border`/`decoration.shadow.color`) — o accent ciano é o tema visual do profile inteiro, não só da bar.

⚠️ **Descoberta:** `~/.config/kitty/` nunca tinha sido stowado — eram arquivos reais (`kitty.conf`/`theme.conf`) com a paleta Vanta Black+Crimson+Rose antiga, completamente desincronizados do que estava no repo (`common/kitty` tinha um `kitty.conf` padrão genérico do próprio kitty + tema Catppuccin Mocha, nunca usado de fato). Resolvido: conteúdo real foi migrado pra `profiles/quickshell/.config/kitty/` com o tema ciano, `common/kitty` (obsoleto) foi removido do repo.

### Arquitetura QML

```
~/.config/quickshell/          (= profiles/quickshell/.config/quickshell/ no repo)
├── qmldir                     # registra singletons Colors e Fonts
├── Colors.qml                 # singleton de cores
├── Fonts.qml                  # singleton de fonte
├── shell.qml                  # entrypoint — importa e monta tudo
├── components/                # primitivos reutilizáveis (ex: PowerMenuItem.qml)
└── modules/
    ├── bar/                   # Workspaces, Clock, SystemStats, PowerMenu, BluetoothPanel
    └── notifications/         # NotificationPopup.qml
```

### Módulos já implementados (todos validados via uso real / boot)

- **Workspaces.qml** — usa `Quickshell.Hyprland`, lê `Hyprland.workspaces` (leitura funciona nativamente). Dispatch de clique usa workaround (ver seção Hyprland Lua abaixo).
- **Clock.qml** — Timer simples, sem dependência externa.
- **SystemStats.qml** — CPU/RAM via `Process` rodando bash + `/proc/stat`/`free`, polling a cada 2s. Funcional mas não é a abordagem mais performática (spawna bash a cada tick); revisar se virar gargalo.
- **PowerMenu.qml** — usa `PopupWindow` (não `Rectangle` filho da PanelWindow — ver seção Popups abaixo). Lock/Logout/Reboot/Shutdown, todos via `Process`.
- **BluetoothPanel.qml** — usa `Quickshell.Bluetooth` nativo (`Bluetooth.defaultAdapter`, `.devices`, propriedade `.paired`, `.connected` gravável). Toggle de power via `Process` + `bluetoothctl power on/off` (não confirmamos se `adapter.enabled` é gravável, então não arriscamos).
- **NotificationPopup.qml** — usa `Quickshell.Services.Notifications` (`NotificationServer`, `trackedNotifications`). Só pode haver UM servidor D-Bus de notificações ativo — **mako foi desativado do autostart**, não rodam em paralelo.
- **VolumeOSD.qml / BrightnessOSD.qml** (`modules/osd/`) — popup de overlay (`components/OSDBar.qml`, compartilhado) que aparece ~1.5s ao mudar volume/brilho. Volume usa binding nativo `Quickshell.Services.Pipewire` (`Pipewire.defaultAudioSink.audio.volume`/`.muted`, com `PwObjectTracker` pra manter o node "vivo") — sem `Process`, totalmente reativo. Brilho não tem binding nativo no Quickshell; usa `Process` chamando `brightnessctl -m set ...` e parseia o output machine-readable (`device,class,current,percent%,max`) pra atualizar a barra. Acionados via `IpcHandler { target: "osd" }` no `shell.qml`, chamado pelos binds do Hyprland com `qs ipc call osd <funcao>` (ver `hyprland.lua`/`keybinds.lua`).
- **Launcher.qml** (`modules/launcher/`) — substitui `wofi --show drun` (SUPER+D). Usa o singleton **nativo** `Quickshell.DesktopEntries` (`.applications.values`, cada `DesktopEntry` com `name`/`icon`/`noDisplay`/`execute()`) — não precisou de script externo nem `gtk-launch`, o próprio `execute()` já trata `Terminal=`/`Exec=`/working directory. Busca é filtro simples (`name.toLowerCase().includes(query)`) sobre os não-`noDisplay`, navegação por `Keys.onUpPressed`/`onDownPressed`/`onReturnPressed`/`onEscapePressed` num `TextInput`. É um `PanelWindow` cobrindo a tela inteira (`anchors` nas 4 bordas, `color: "transparent"`, `focusable` ligado só quando aberto) com o conteúdo real centralizado por dentro (`Rectangle` com `anchors.centerIn: parent`) — padrão diferente do `PopupWindow` ancorado à bar (ver seção Popups); usar esse padrão pra qualquer modal futuro que precise cobrir a tela toda. Acionado via `IpcHandler { target: "launcher" }` + `qs ipc call launcher toggle`.

### ⚠️ Descoberta crítica: Hyprland 0.55+ (Lua) quebra dispatch externo

Hyprland 0.55+ migrou a config pra Lua nativo. Isso quebrou a sintaxe **antiga** de `hyprctl dispatch <ação> <args>` vinda de fora (CLI, ou o binding nativo `Hyprland.dispatch()` do Quickshell, que ainda manda a sintaxe velha por baixo dos panos).

**Sintoma:** erro tipo `error: [string "return hl.dispatch(workspace 3)"]:1: ')' expected near '3'`.

**Workaround adotado neste projeto:** usar `Quickshell.Io.Process` pra chamar `hyprctl dispatch` diretamente com a sintaxe Lua nova:
```qml
Process {
    id: dispatchProc
}
// ...
dispatchProc.command = ["hyprctl", "dispatch", "hl.dsp.focus({workspace=\"" + id + "\"})"]
dispatchProc.running = true
```

Leitura de estado (`Hyprland.workspaces`, etc.) continua funcionando normalmente pelo binding nativo — só o **dispatch de comandos** que precisa desse contorno. **Aplicar esse padrão em qualquer módulo futuro que dispare ações no Hyprland** (ex: launcher, se precisar focar janelas).

Versão confirmada em uso: Hyprland 0.56.2.

### ⚠️ Popups/dropdowns precisam ser `PopupWindow`, não `Rectangle` filho

Uma `PanelWindow` no Wayland/layer-shell tem superfície de tamanho fixo — conteúdo não pode "vazar" visualmente pra fora dela. Um `Rectangle` posicionado com `anchors.top: parent.bottom` fica cortado/invisível.

**Padrão correto:** usar `PopupWindow` com `anchor.window: <referência à PanelWindow pai>` e `anchor.rect.x/y` pra posicionamento. A `PanelWindow` pai precisa ter `id` e ser passada como propriedade pro componente filho (ex: `barWindow: bar`).

Ver `PowerMenu.qml` e `BluetoothPanel.qml` como referência de implementação.

### ⚠️ `PanelWindow.layer` não existe — usar attached property `WlrLayershell.layer`

O tipo `PanelWindow` (via `import Quickshell.Wayland`, que reexporta `Quickshell._Window`) é a abstração cross-platform e **não tem** propriedade `layer` própria — só `anchors`, `margins`, `exclusiveZone`, `exclusionMode`, `aboveWindows`, `focusable`. A propriedade de layer-shell (`Background`/`Bottom`/`Top`/`Overlay`) é uma **attached property** do tipo `WlrLayershell` (`Quickshell.Wayland._WlrLayerShell`, importado transitivamente por `Quickshell.Wayland`):

```qml
PanelWindow {
    WlrLayershell.layer: WlrLayer.Overlay   // não "layer: WlrLayer.Overlay"
}
```

Erro sintoma se usar a forma errada: `Cannot assign to non-existent property "layer"`.

### Quickshell recarrega QML sozinho ao salvar (hot-reload)

Diferente do autostart do Hyprland (que só recarrega em boot real — ver Pendências), o **Quickshell observa os próprios arquivos QML e recarrega a config automaticamente ao detectar mudança salva em disco**. Não precisa matar/reiniciar o processo pra testar uma alteração de módulo. Log confirma com `INFO: Reloading configuration...` / `INFO: Configuration Loaded` em `~/.local/state` ou via `journalctl`/log do processo.

⚠️ Matar o processo `quickshell` manualmente (pra forçar um restart limpo, por exemplo) **dispara o D-Bus a auto-ativar o `mako`** como fallback do serviço `org.freedesktop.Notifications` enquanto o quickshell está fora do ar — mesmo com o autostart do mako desativado. Se isso acontecer, rodar `pkill -x mako` depois que o quickshell voltar (ele detecta o nome D-Bus livre e registra de novo sozinho).

### Brilho: `brightnessctl` e sintaxe de delta

`brightnessctl` funciona nesta máquina **sem precisar de sudo ou grupo `video`** — ele usa o D-Bus do `logind` quando disponível, caindo pro sysfs direto só se não houver. Adicionar o usuário ao grupo `video` (feito durante a implementação do OSD) não foi estritamente necessário, mas serve de fallback caso o logind não esteja disponível (ex: fora de uma sessão gráfica).

Sintaxe de delta é **sufixo, não prefixo**: `5%-` (diminuir 5%) e `+5%` (aumentar 5%). `-5%` é inválido — `brightnessctl` interpreta como flag desconhecida e falha silenciosamente do ponto de vista do QML (Process só reporta erro se você checar `exitCode`/stderr).

### Sobre ícones Nerd Font

Nunca copiar/colar o glyph visual direto no código — o codepoint pode corromper no processo de clipboard. Preferir escape Unicode explícito (`"\uf293"`) ou, quando a certeza do codepoint for baixa, usar texto simples como fallback temporário em vez de travar o progresso.

### Deprecations conhecidas (Quickshell 0.3.0)

- `PanelWindow.height` → usar `implicitHeight`

## Pendências conhecidas

1. **`profiles/classic/hypr` não é symlinkado via Stow.** `~/.config/hypr/` são arquivos reais soltos, desincronizados do repo por padrão — qualquer edição precisa ser copiada manualmente pro repo antes do commit (já aconteceu 2x: `autostart.lua` pra waybar e pra mako). Antes de rodar `stow` nesse pacote, validar se há mais divergências além do `autostart.lua`, pra não perder config real.
2. **SystemStats.qml spawna um processo bash a cada 2s** — funcional, mas não é a abordagem mais leve. Candidato a otimização futura (ler `/proc/stat` direto em QML/JS).
3. **Autostart do Hyprland só recarrega em boot real**, não em `hyprctl reload`. Qualquer mudança em `hl.on("hyprland.start", ...)` exige logout/login ou reboot completo pra validar — não adianta só editar e recarregar config.

## Preferências de trabalho

- Git discipline: branch de isolamento (`quickshell-migration`) antes de mudanças grandes, commit em cada marco validado.
- Validar cada módulo antes de avançar pro próximo (não acumular mudanças não testadas).
- Comandos de terminal diretos (incluindo heredoc pra criação de arquivo) são preferíveis a instruções vagas tipo "edite o arquivo X".
- Quando a API/sintaxe exata de algo for incerta (nome de propriedade QML, codepoint de ícone, etc.), ser explícito sobre a incerteza em vez de apresentar como certeza — evita gastar ciclos de debug com informação errada apresentada como fato.
