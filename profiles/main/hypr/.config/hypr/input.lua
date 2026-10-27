---------------
---- INPUT ----
---------------

hl.config({
    input = {
        -- us (padrão) + br do teclado ThinkPad: a variante põe / ? no Ctrl
        -- direito, já que ele não tem a tecla /? do ABNT2. Os dois Shifts
        -- juntos alternam (os dois Alts roubariam o AltGr do br). Indicador na
        -- waybar (hyprland/language)
        kb_layout  = "us,br",
        kb_variant = ",thinkpad",
        kb_model   = "",
        kb_options = "grp:shifts_toggle",
        kb_rules   = "",

        follow_mouse = 1,

        sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.

        touchpad = {
            natural_scroll = false,
        },
    },
})

hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace"
})

-- Example per-device config
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Devices/ for more
hl.device({
    name        = "epic-mouse-v1",
    sensitivity = -0.5,
})

-- Zoom de tela no touchpad: pinça de 2 dedos segurando CTRL + WIN, contínuo
-- (segue os dedos). Arrastar 2 dedos é scroll, não gesto: esse cai no
-- CTRL + WIN + scroll do binds.lua, em degraus. Sem mods, a pinça roubaria o
-- zoom de página do Firefox
hl.gesture({
    fingers   = 2,
    direction = "pinch",
    mods      = "CTRL + SUPER",
    action    = "cursorZoom",
    mode      = "live",
})
