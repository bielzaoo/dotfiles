-------------------------
---- MODO FLUTUANTE ----
-------------------------

-- SUPER+ALT+V: todas as janelas viram flutuantes, como num desktop
-- tradicional (arrasta pela barra do app ou com SUPER+arrastar). De novo,
-- volta tudo pro tiling. Alt+Tab troca de janela e traz ela pra frente.
--
-- Só volta pro tiling o que o modo fez flutuar (tag `modofloat`): TUIs,
-- Bitwarden, diálogos e o que você flutuou na mão seguem flutuando.
-- O estado mora num arquivo em $XDG_RUNTIME_DIR: o `hyprctl reload` (que o
-- repinta faz) reexecuta a config, e sem isso o modo "esqueceria" que está
-- ligado. As tags ficam nas janelas, então sobrevivem ao reload.

local TAG = "modofloat"
local estado = (os.getenv("XDG_RUNTIME_DIR") or "/tmp") .. "/hypr-modo-flutuante"

local function ligado()
    local f = io.open(estado, "r")
    if f then f:close(); return true end
    return false
end

local function xy(v) -- at/size vêm como {x=,y=} ou {1,2}
    if type(v) ~= "table" then return nil end
    return v.x or v[1], v.y or v[2]
end

-- Flutua e marca. Com `geo` ({x,y,w,h}), a janela fica exatamente onde estava no tiling:
-- sem isso o Hyprland usa o tamanho preferido do app (o Chrome e o kitty
-- pedem a tela inteira e cobrem a barra)
local function marca(w, geo)
    local sel = "address:" .. w.address
    hl.dispatch(hl.dsp.window.float({ action = "enable", window = sel }))
    hl.dispatch(hl.dsp.window.tag({ tag = "+" .. TAG, window = sel }))
    if geo then
        -- resize primeiro (ele recentra), depois o move pro ponto exato
        hl.dispatch(hl.dsp.window.resize({ x = geo.w, y = geo.h, window = sel }))
        hl.dispatch(hl.dsp.window.move({ x = geo.x, y = geo.y, window = sel }))
    end
end

local function tem_tag(w)
    if type(w.tags) == "table" then
        for _, t in ipairs(w.tags) do
            if t == TAG then return true end
        end
        return false
    end
    return type(w.tags) == "string" and w.tags:find(TAG, 1, true) ~= nil
end

local function avisa(txt)
    hl.exec_cmd("notify-send -a osd -t 1500 'modo flutuante: " .. txt .. "'")
end

local function liga()
    -- As janelas que já existem ficam onde estavam no tiling (agora soltas).
    -- Fotografa TODAS antes de soltar a primeira: cada uma que sai do tiling
    -- faz o layout redistribuir as que sobram (e w.at/w.size são lidos ao vivo)
    local fila = {}
    for _, w in ipairs(hl.get_windows({ mapped = true })) do
        if not w.floating and (w.fullscreen or 0) == 0 then
            local x, y = xy(w.at)
            local lw, lh = xy(w.size)
            fila[#fila + 1] = { w = w, geo = x and lw and { x = x, y = y, w = lw, h = lh } or nil }
        end
    end
    for _, item in ipairs(fila) do marca(item.w, item.geo) end
    local f = io.open(estado, "w")
    if f then f:close() end
    avisa("ligado")
end

local function desliga()
    os.remove(estado)
    for _, w in ipairs(hl.get_windows({ mapped = true })) do
        if tem_tag(w) then
            local sel = "address:" .. w.address
            hl.dispatch(hl.dsp.window.tag({ tag = "-" .. TAG, window = sel }))
            if w.floating then
                hl.dispatch(hl.dsp.window.float({ action = "disable", window = sel }))
            end
        end
    end
    avisa("desligado")
end

-- Janela nova com o modo ligado: flutua, 60% x 65% do monitor, centralizada
hl.on("window.open", function(w)
    -- a janela chega como userdata (não table)
    if not ligado() or w == nil or not w.address then return end
    if w.floating or (w.fullscreen or 0) ~= 0 then return end
    marca(w, nil)
    local m = w.monitor
    if m and m.width then
        local sel = "address:" .. w.address
        hl.dispatch(hl.dsp.window.resize({
            x = math.floor(m.width * 0.60 / (m.scale or 1)),
            y = math.floor(m.height * 0.65 / (m.scale or 1)),
            window = sel,
        }))
        hl.dispatch(hl.dsp.window.center({ window = sel }))
    end
end)

-- Global de propósito: dá pra alternar de fora (script/teste) com
-- hyprctl dispatch 'function() ModoFlutuante() end'
function _G.ModoFlutuante()
    if ligado() then desliga() else liga() end
end
hl.bind("SUPER + ALT + V", ModoFlutuante, { desc = "Modo flutuante: todas as janelas soltas (alternar)" })

-- Alt+Tab: próxima janela do workspace, trazida pra frente (no tiling o
-- bring_to_top não muda nada; no flutuante é o que faz ela aparecer)
hl.bind("ALT + Tab", function()
    hl.dispatch(hl.dsp.window.cycle_next())
    hl.dispatch(hl.dsp.window.bring_to_top())
end, { desc = "Próxima janela (Alt+Tab)" })
hl.bind("ALT + SHIFT + Tab", function()
    hl.dispatch(hl.dsp.window.cycle_next({ next = false }))
    hl.dispatch(hl.dsp.window.bring_to_top())
end, { desc = "Janela anterior (Alt+Shift+Tab)" })
