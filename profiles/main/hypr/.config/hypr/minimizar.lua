-------------------
---- MINIMIZAR ----
-------------------

-- O Hyprland não tem minimizar: a janela vai pro workspace especial
-- `minimizadas` (escondido, sem trocar de tela) e volta pelo menu
-- `minimizadas` (SUPER+SHIFT+N ou clique no 󰖰 da waybar), no workspace atual.
-- O botão "–" dos apps com barra própria (Chrome, Firefox) cai aqui também.

local ESPECIAL = "special:minimizadas"

local function minimiza(w)
    if w == nil or not w.address then return end
    if w.workspace and w.workspace.name == ESPECIAL then return end
    hl.dispatch(hl.dsp.window.move({ workspace = ESPECIAL, window = "address:" .. w.address, follow = false }))
    hl.exec_cmd("pkill -RTMIN+10 -x waybar")   -- contador 󰖰 da waybar
end

-- Global de propósito: dá pra minimizar de fora (script/teste) com
-- hyprctl dispatch 'function() Minimiza() end'
function _G.Minimiza()
    minimiza(hl.get_active_window())
end

hl.bind("SUPER + N", Minimiza, { desc = "Minimizar janela" })
hl.bind("SUPER + SHIFT + N", hl.dsp.exec_cmd("minimizadas"), { desc = "Restaurar janela minimizada (menu)" })

-- Pedido do app (botão "–" na barra dele). O 2º argumento, se vier, diz se é
-- minimizar (true) ou desfazer (false): só o "true" (ou ausente) minimiza.
hl.on("window.minimize", function(w, quer)
    if quer == false or quer == 0 then return end
    minimiza(w)
end)
