-- Programas padrão, usados pelos binds e pelo autostart
return {
    terminal      = "kitty -e tmux-entra",  -- WIN+Q: já dentro do tmux
    terminal_puro = "kitty",                -- WIN+SHIFT+Q: shell sem tmux
    menu          = "vicinae toggle",       -- launcher Tier 2 (Fase 4); servidor sobe no autostart
}
