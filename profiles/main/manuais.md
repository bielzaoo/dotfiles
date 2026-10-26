# Instalados fora do pacman

O `pacotes.txt` só cobre os repos oficiais. Isto aqui vem de outro lugar e o
bootstrap precisa buscar à parte.

| O quê | Onde fica | Origem | Versão |
|---|---|---|---|
| Vicinae (launcher + clipboard) | `~/.local/opt/vicinae`, link em `~/.local/bin/vicinae` | tarball do release no GitHub (`vicinaehq/vicinae`) | v0.29.2 |
| Cozette (`CozetteVector`) | `~/.local/share/fonts/cozette/` | release no GitHub (`slavfox/Cozette`), `.ttf` vetorizadas | — |
| Spleen | `~/.local/share/fonts/spleen/` | release no GitHub (`fcambus/spleen`), `.otf` | — |

Depois de copiar as fontes: `fc-cache -f`.

Deps do Vicinae que vêm do pacman (já no `pacotes.txt`, marcadas explícitas):
`qtkeychain-qt6 syntax-highlighting layer-shell-qt libqalculate`.

Fora do pacman e **fora deste repo** (config de sistema, ver doc de restore no
brain): `/etc/nftables.conf`, conexão `wg0` do NetworkManager, config do
snapper + hook `04-uki-backup`, hardening (playbook Ansible no brain).
