# ls -> eza, cd -> zoxide e prompt do starship no bash (mesmo do
# common/zsh/.config/zsh/modern-cli.zsh). Carregado no fim do ~/.bashrc.

if command -v eza &>/dev/null; then
    alias ls='eza --icons=auto --group-directories-first'
    alias ll='eza -l --icons=auto --group-directories-first --git'
    alias la='eza -la --icons=auto --group-directories-first --git'
    alias l='la'
    alias lt='eza --tree --level=2 --icons=auto --group-directories-first'
fi

# Prompt do common/starship (logo do Arch, git, tempo do comando)
if command -v starship &>/dev/null; then
    eval "$(starship init bash)"
fi

# --cmd cd: o próprio `cd` passa a ser o zoxide (aprende as pastas que você
# visita; `cd proj` pula pra ~/algum/lugar/projeto). `cdi` abre a busca
# interativa com fzf. Fica por último: ele se pendura no PROMPT_COMMAND
# depois do starship.
if command -v zoxide &>/dev/null; then
    eval "$(zoxide init bash --cmd cd)"
fi
