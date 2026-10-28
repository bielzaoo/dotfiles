-- Programas padrão, usados pelos binds e pelo autostart
return {
    terminal      = "kitty -e tmux-entra",  -- WIN+Enter: já dentro do tmux
    terminal_puro = "kitty",                -- WIN+SHIFT+Enter: shell sem tmux
    menu          = "vicinae toggle",       -- launcher Tier 2 (Fase 4); servidor sobe no autostart
    arquivos      = "kitty -e yazi",        -- WIN+F: file manager no terminal (kitty puro: prévia de imagem sem passthrough do tmux)
    arquivos_gui  = "nautilus",             -- WIN+SHIFT+F: GUI p/ arrastar pro navegador, montar pendrive/celular
}
