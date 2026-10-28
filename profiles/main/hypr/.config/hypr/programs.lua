-- Programas padrão, usados pelos binds e pelo autostart
return {
    terminal      = "kitty -e tmux-entra",  -- WIN+Q: já dentro do tmux
    terminal_puro = "kitty",                -- WIN+SHIFT+Q: shell sem tmux
    menu          = "vicinae toggle",       -- launcher Tier 2 (Fase 4); servidor sobe no autostart
    arquivos      = "kitty -e yazi",        -- WIN+E: file manager no terminal (kitty puro: prévia de imagem sem passthrough do tmux)
    arquivos_gui  = "nautilus",             -- WIN+SHIFT+E: GUI p/ arrastar pro navegador, montar pendrive/celular
}
