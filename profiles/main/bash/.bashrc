#
# ~/.bashrc  (dotfiles: profiles/main/bash)
#
# O /etc/bash.bashrc já carrega o bash-completion. Cores do prompt e do fzf são
# ANSI puras, então seguem o rodízio de `cor` sem gerar nada.

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

export PATH="$HOME/.local/bin:$PATH"
export EDITOR=vim VISUAL=vim
export CLAUDE_OLLAMA_MODEL=glm-5.3

# Histórico: grande, sem duplicata, compartilhado entre terminais abertos
HISTSIZE=50000
HISTFILESIZE=100000
HISTCONTROL=ignoreboth:erasedups
HISTTIMEFORMAT='%F %T  '
shopt -s histappend cmdhist
PROMPT_COMMAND+=('history -a; history -n')

# ** recursivo, corrige typo no cd, digitar só a pasta entra nela
shopt -s checkwinsize globstar cdspell dirspell autocd

# Listagem: eza (ícones Nerd Font, git, pastas primeiro) quando houver; senão o
# ls de sempre. `ll` detalhado, `la` com ocultos, `lt` em árvore.
if command -v eza >/dev/null; then
    alias ls='eza --group-directories-first --icons=auto'
    alias ll='eza -lh  --group-directories-first --icons=auto --git'
    alias la='eza -lha --group-directories-first --icons=auto --git'
    alias lt='eza --tree --level=2 --group-directories-first --icons=auto'
else
    alias ls='ls --color=auto --group-directories-first'
    alias ll='ls -lh'
    alias la='ls -lhA'
fi
alias grep='grep --color=auto'
alias diff='diff --color=auto'
alias ip='ip -color=auto'
alias ..='cd ..'
alias ...='cd ../..'

# fzf: Ctrl+R histórico, Ctrl+T arquivo, Alt+C entra em pasta.
# --color=16 = usa só as 16 cores ANSI do kitty (segue a paleta ativa)
if command -v fzf >/dev/null; then
  #: Ctrl+R | Buscar no histórico (fzf)
  #: Ctrl+T | Buscar arquivo e colar o caminho (fzf)
  #: Alt+C | Buscar pasta e entrar (fzf)
  export FZF_DEFAULT_OPTS='--color=16 --layout=reverse --height=40% --border=sharp --info=inline'
  eval "$(fzf --bash)"
fi

# zoxide no lugar do cd: `cd caminho` funciona igual, `cd parte-do-nome` pula
# pra pasta frequente, `cdi` escolhe no fzf. O cd original segue em `builtin cd`
#: cd parte-do-nome | Pular pra pasta frequente (zoxide)
#: cdi | Escolher pasta frequente no fzf (zoxide)
#: sessao | Escolher pasta e entrar na sessão tmux dela
command -v zoxide >/dev/null && eval "$(zoxide init bash --cmd cd)"

# Prompt: starship quando houver (tema em ~/.config/starship.toml, cores em
# nomes ANSI pra seguir a paleta do kitty). Sem starship, cai no prompt antigo:
# pasta (ativo) · branch git (apagado) · código de saída (erro), $ verde se o
# último comando deu certo. Papéis iguais aos do repinta (color7/8/9/10).
if command -v starship >/dev/null; then
  # O repinta aponta este link pro prompt do modo (Desktop = pílulas powerline)
  [[ -e ~/.config/tema/starship-atual.toml ]] && export STARSHIP_CONFIG=~/.config/tema/starship-atual.toml
  eval "$(starship init bash)"
else
  if [[ -r /usr/share/git/completion/git-prompt.sh ]]; then
    . /usr/share/git/completion/git-prompt.sh
    GIT_PS1_SHOWDIRTYSTATE=1 GIT_PS1_SHOWUNTRACKEDFILES=1 GIT_PS1_SHOWUPSTREAM=auto
  fi
  __prompt() {
    local s=$? g=''
    local dim='\[\e[90m\]' erro='\[\e[91m\]' ok='\[\e[92m\]' ativo='\[\e[37m\]' r='\[\e[0m\]'
    PS1=''
    [[ -n $SSH_CONNECTION ]] && PS1+="$dim\u@\h$r "
    PS1+="$ativo\w$r"
    declare -F __git_ps1 >/dev/null && g=$(__git_ps1 ' %s')
    PS1+="$dim$g$r"
    if ((s)); then PS1+=" $erro[$s]$r $erro\$$r "; else PS1+=" $ok\$$r "; fi
  }
  PROMPT_COMMAND=(__prompt "${PROMPT_COMMAND[@]}")
fi

# ssh-agent do systemd (ssh-agent.socket); chave entra no 1º uso via AddKeysToAgent
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"

# >>> dotfiles ssh-agent >>>
[[ -f "$HOME/.local/bin/ssh-agent-init" ]] && source "$HOME/.local/bin/ssh-agent-init"
# <<< dotfiles ssh-agent <<<
