---------------------
---- KEYBINDINGS ----
---------------------

-- Todo bind leva `desc`: o `atalhos` (WIN+K) lê do `hyprctl binds -j`, e em
-- config Lua o JSON não diz o que o bind faz, só a descrição.

local programs = require("programs")
local mainMod = "SUPER" -- Sets "Windows" key as main modifier

-- Example binds, see https://wiki.hypr.land/Configuring/Basics/Binds/ for more
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(programs.terminal), { desc = "Abrir terminal (tmux)" })
hl.bind(mainMod .. " + SHIFT + Return", hl.dsp.exec_cmd(programs.terminal_puro), { desc = "Abrir terminal sem tmux" })
local closeWindowBind = hl.bind(mainMod .. " + W", hl.dsp.window.close(), { desc = "Fechar janela" })
-- closeWindowBind:set_enabled(false)
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"), { desc = "Sair do Hyprland" })
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }), { desc = "Janela flutuante (alternar)" })
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(programs.menu), { desc = "Launcher (Vicinae)" })
hl.bind(mainMod .. " + F", hl.dsp.exec_cmd(programs.arquivos), { desc = "Arquivos (yazi)" })
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.exec_cmd(programs.arquivos_gui), { desc = "Arquivos (Nautilus)" })
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo(), { desc = "Pseudo-tile (alternar)" })
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"), { desc = "Trocar direção do split" })    -- dwindle only
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("loginctl lock-session"), { desc = "Bloquear tela" })
hl.bind(mainMod .. " + Escape", hl.dsp.exec_cmd("energia"), { desc = "Menu de energia" })
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd("tema"), { desc = "Seletor de cor/fonte/espaço/fundo" })
hl.bind(mainMod .. " + K", hl.dsp.exec_cmd("atalhos"), { desc = "Atalhos (esta lista)" })
hl.bind(mainMod .. " + SHIFT + V", hl.dsp.exec_cmd("vicinae deeplink 'vicinae://launch/clipboard/history?toggle=true'"), { desc = "Histórico do clipboard" })  -- histórico mora no Vicinae: trocar launcher = resolver clipboard junto

-- Screenshot: Print = área selecionada, SHIFT + Print = tela inteira (vai pro clipboard)
hl.bind("Print",         hl.dsp.exec_cmd('grim -g "$(slurp)" - | wl-copy'), { desc = "Screenshot de área (clipboard)" })
hl.bind("SHIFT + Print", hl.dsp.exec_cmd("grim - | wl-copy"),               { desc = "Screenshot da tela (clipboard)" })

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }),  { desc = "Foco à esquerda" })
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }), { desc = "Foco à direita" })
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }),    { desc = "Foco acima" })
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }),  { desc = "Foco abaixo" })

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key,             hl.dsp.focus({ workspace = i}),        { desc = "Ir pro workspace " .. i })
    hl.bind(mainMod .. " + SHIFT + " .. key,     hl.dsp.window.move({ workspace = i }), { desc = "Mover janela pro workspace " .. i })
end

-- Example special workspace (scratchpad)
hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"),            { desc = "Scratchpad (mostrar/esconder)" })
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }), { desc = "Mover janela pro scratchpad" })

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }), { desc = "Próximo workspace" })
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }), { desc = "Workspace anterior" })

-- Zoom de tela com CTRL + mainMod + scroll (centrado no cursor); CTRL + mainMod + 0 reseta
-- passo = multiplicador por clique do scroll (velocidade da animação: zoomFactor em look.lua)
local passo = 1.3
local function zoom(mult)
    return function()
        local z = tonumber(hl.get_config("cursor.zoom_factor")) or 1
        z = math.max(1, math.min(z * mult, 10))
        hl.config({ cursor = { zoom_factor = z } })
    end
end
hl.bind("CTRL + " .. mainMod .. " + mouse_up",   zoom(passo), { desc = "Zoom: aproximar" })
hl.bind("CTRL + " .. mainMod .. " + mouse_down", zoom(1 / passo), { desc = "Zoom: afastar" })
hl.bind("CTRL + " .. mainMod .. " + 0", function() hl.config({ cursor = { zoom_factor = 1 } }) end, { desc = "Zoom: resetar" })

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true, desc = "Arrastar janela" })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true, desc = "Redimensionar janela" })

-- Laptop multimedia keys for volume and LCD brightness
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("osd vol up"),     { locked = true, repeating = true, desc = "Volume +" })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("osd vol down"),   { locked = true, repeating = true, desc = "Volume -" })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("osd vol mute"),   { locked = true, repeating = true, desc = "Mudo (alternar)" })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("osd mic mute"),   { locked = true, repeating = true, desc = "Microfone mudo (alternar)" })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("osd luz up"),     { locked = true, repeating = true, desc = "Brilho +" })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("osd luz down"),   { locked = true, repeating = true, desc = "Brilho -" })

-- Requires playerctl
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true, desc = "Mídia: próxima" })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true, desc = "Mídia: tocar/pausar" })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true, desc = "Mídia: tocar/pausar" })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true, desc = "Mídia: anterior" })

-- Notificações (mako), à la Omarchy. Clicar na notificação também vai pra origem
hl.bind(mainMod .. " + comma",               hl.dsp.exec_cmd("makoctl dismiss"),       { desc = "Notificação: fechar a última" })
hl.bind(mainMod .. " + SHIFT + comma",       hl.dsp.exec_cmd("makoctl dismiss --all"), { desc = "Notificação: fechar todas" })
hl.bind(mainMod .. " + ALT + comma",         hl.dsp.exec_cmd("makoctl invoke"),        { desc = "Notificação: ir pra origem" })
hl.bind(mainMod .. " + SHIFT + ALT + comma", hl.dsp.exec_cmd("makoctl restore"),       { desc = "Notificação: reabrir a última fechada" })
hl.bind(mainMod .. " + CTRL + comma",        hl.dsp.exec_cmd("makoctl mode -t nao-perturbe && notify-send -a osd -t 1500 \"não perturbe: $(makoctl mode | grep -q nao-perturbe && echo ligado || echo desligado)\""), { desc = "Notificação: não perturbe (alternar)" })

-- Duplo clique no wallpaper (fora de janela e da waybar) abre o seletor de
-- fundo, à la Omarchy. Bind non_consuming: o clique segue pra quem está embaixo,
-- e a checagem roda aqui no Lua, sem processo por clique. Lua não tem relógio
-- em ms, então a janela do duplo clique é um timer oneshot por clique; a
-- geração descarta o timer de um clique que já foi substituído.
local CLIQUES, JANELA_MS = 2, 400
local cliques, geracao = 0, 0
local function no_wallpaper()
    local p, m = hl.get_cursor_pos(), hl.get_monitor_at_cursor()
    if not p or not m then return false end
    local r = m.reserved -- área da waybar e afins
    if p.x < m.x + r.left or p.x >= m.x + m.width - r.right
        or p.y < m.y + r.top or p.y >= m.y + m.height - r.bottom then return false end
    -- w.visible é true até em workspace de fundo: quem diz se está na tela é
    -- o workspace (cobre o special aberto também)
    for _, w in ipairs(hl.get_windows({ mapped = true })) do
        if w.workspace and w.workspace.visible and not w.hidden
            and p.x >= w.at.x and p.x < w.at.x + w.size.x
            and p.y >= w.at.y and p.y < w.at.y + w.size.y then return false end
    end
    return true
end
hl.bind("mouse:272", function()
    if not no_wallpaper() then cliques = 0; return end
    cliques, geracao = cliques + 1, geracao + 1
    if cliques >= CLIQUES then
        cliques = 0
        hl.exec_cmd("tema fundo")
        return
    end
    local g = geracao
    hl.timer(function() if g == geracao then cliques = 0 end end, { timeout = JANELA_MS, type = "oneshot" })
end, { non_consuming = true, desc = "Duplo clique no wallpaper: seletor de fundo" })
