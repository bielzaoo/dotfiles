# Prompt em zsh puro, no lugar do starship (que não está nos repositórios
# do Fedora). Minimalista, numa linha só: ⚡ → pasta, mais git, virtualenv e
# tempo do último comando quando houver, em Catppuccin sobre fundo preto.
# Os ícones vêm dos símbolos Nerd Font que o kitty já traz embutidos.
#
# Segurança: o PROMPT é montado no precmd SEM `prompt_subst`, e o nome da
# branch/venv tem os `%` escapados. Assim um repositório clonado com uma
# branch tipo `$(comando)` não executa nada nem bagunça o prompt.

autoload -Uz vcs_info add-zsh-hook
zmodload zsh/datetime
setopt no_prompt_subst

zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' stagedstr '+'
zstyle ':vcs_info:git:*' unstagedstr '!'
zstyle ':vcs_info:git:*' formats '%F{#cba6f7}'$''' %b%f%F{#f9e2af}%c%u%f '
zstyle ':vcs_info:git:*' actionformats '%F{#cba6f7}'$''' %b|%a%f%F{#f9e2af}%c%u%f '
zstyle ':vcs_info:git*+set-message:*' hooks _prompt_escape _prompt_untracked

+vi-_prompt_escape() {
    hook_com[branch]=${hook_com[branch]//\%/%%}
}

+vi-_prompt_untracked() {
    [[ -n $(git ls-files --others --exclude-standard --directory --no-empty-directory 2>/dev/null | head -n1) ]] &&
        hook_com[unstaged]+='?'
}

_prompt_preexec() { _prompt_start=$EPOCHREALTIME }

_prompt_precmd() {
    vcs_info

    local dur=''
    if [[ -n $_prompt_start ]]; then
        local -i s=$(( EPOCHREALTIME - _prompt_start ))
        if (( s >= 60 )); then
            dur="$(( s / 60 ))m$(( s % 60 ))s"
        elif (( s >= 2 )); then
            dur="${s}s"
        fi
        unset _prompt_start
    fi

    # Uma linha só: raio, seta (vermelha se o último comando falhou) e o nome
    # da pasta atual. Git, venv e tempo só aparecem quando fazem sentido.
    local p=''
    p+='%F{#f9e2af}'$'\uf0e7''%f '
    # Usuário/host só numa sessão SSH; root sempre em vermelho.
    if [[ -n $SSH_CONNECTION ]]; then
        p+='%(!.%B%F{#f38ba8}.%F{#fab387})%n@%m%f%b '
    elif (( EUID == 0 )); then
        p+='%B%F{#f38ba8}%n%f%b '
    fi
    p+='%(?.%F{#a6adc8}.%F{#f38ba8})'$'\u2192''%f '
    p+='%B%F{#cdd6f4}%1~%f%b '
    p+=$vcs_info_msg_0_
    [[ -n $VIRTUAL_ENV ]] && p+="%F{#f9e2af}"$'\ue73c'" ${${VIRTUAL_ENV:t}//\%/%%}%f "
    [[ -n $dur ]] && p+="%F{#6c7086}"$'\uf252'" $dur%f "

    PROMPT=$p
}

add-zsh-hook preexec _prompt_preexec
add-zsh-hook precmd _prompt_precmd
