--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

-- Example window rules that are useful

local suppressMaximizeRule = hl.window_rule({
    -- Ignore maximize requests from all apps. You'll probably like this.
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})
-- suppressMaximizeRule:set_enabled(false)

hl.window_rule({
    -- Fix some dragging issues with XWayland
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})

-- Layer rules also return a handle.
-- local overlayLayerRule = hl.layer_rule({
--     name  = "no-anim-overlay",
--     match = { namespace = "^my-overlay$" },
--     no_anim = true,
-- })
-- overlayLayerRule:set_enabled(false)

-- Hyprland-run windowrule
hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },

    move  = "20 monitor_h-120",
    float = true,
})

-- Painéis TUI (Fase 6): ~/.local/bin/tui abre kitty com class tui-<nome>
hl.window_rule({
    name  = "tui-painel",
    match = { class = "tui-.*" },

    float  = true,
    size   = "900 560",
    center = true,
})

-- Workspaces 1-5 sempre existem (persistentes), mesmo vazios: a waybar
-- (ext/workspaces) mostra o que o compositor anuncia, então é aqui que fixa
for i = 1, 5 do
    hl.workspace_rule({ workspace = tostring(i), persistent = true })
end

-- Web apps (Chromium/Chrome, class chrome-<host>__-Default) podem pedir foco:
-- clicar na notificação (ex.: WhatsApp) leva até a janela. Só eles: o global
-- misc.focus_on_activate deixaria qualquer app roubar o foco
hl.window_rule({
    name  = "webapp-foco",
    match = { class = "chrome-.*" },

    focus_on_activate = true,
})
