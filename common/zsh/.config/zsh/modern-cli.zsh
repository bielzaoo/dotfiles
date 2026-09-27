# ls -> eza e cd -> zoxide. Carregado no fim do ~/.zshrc (depois do
# oh-my-zsh, que define os próprios aliases de ls/ll/la).

if command -v eza &>/dev/null; then
    alias ls='eza --icons=auto --group-directories-first'
    alias ll='eza -l --icons=auto --group-directories-first --git'
    alias la='eza -la --icons=auto --group-directories-first --git'
    alias l='la'
    alias lt='eza --tree --level=2 --icons=auto --group-directories-first'
fi

# --cmd cd: o próprio `cd` passa a ser o zoxide (aprende as pastas que você
# visita; `cd proj` pula pra ~/algum/lugar/projeto). `cdi` abre a busca
# interativa com fzf. Precisa ficar no fim do .zshrc.
if command -v zoxide &>/dev/null; then
    eval "$(zoxide init zsh --cmd cd)"
fi
