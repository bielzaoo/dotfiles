local mainMod = "SUPER"

hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + M", hl.dsp.exit())
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("hyprlock"))
hl.bind("CTRL + SUPER + mouse_up", hl.dsp.exec_cmd("bash ~/.config/hypr/zoom.sh '+ 0.5'"))
hl.bind("CTRL + SUPER + mouse_down", hl.dsp.exec_cmd("bash ~/.config/hypr/zoom.sh '- 0.5'"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("bash ~/.config/hypr/scripts/screenshot.sh area"))
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.exec_cmd("bash ~/.config/hypr/scripts/screenshot.sh full"))
hl.bind(mainMod .. " + A", hl.dsp.exec_cmd("bash ~/.config/hypr/scripts/appmenu.sh"))
-- hl.bind(mainMod .. " + V",         hl.dsp.exec_cmd("cliphist list | wofi --dmenu | cliphist decode | wl-copy"))
hl.bind(
	mainMod .. " + SHIFT + V",
	hl.dsp.exec_cmd("bash -c 'cliphist list | wofi --dmenu | cliphist decode | wl-copy'")
)

hl.bind(mainMod .. " + S", hl.dsp.layout("togglesplit"))

-- Navegação entre workspaces (1 a 9)
for i = 1, 9 do
	hl.bind(mainMod .. " + " .. i, hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end

-- === Fullscreen / pseudo / split ===
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ action = "toggle" }))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + CTRL + J", hl.dsp.layout("togglesplit"))

-- Navegar entre janelas (vim-like)
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "r" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "d" }))

-- Trocar de posição com a janela vizinha
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.swap({ direction = "l" }))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.swap({ direction = "r" }))
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.swap({ direction = "u" }))
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.swap({ direction = "d" }))

-- Scroll do mouse pra trocar workspace
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "-1" }))

-- === Mover e redimensionar com o mouse (arrastando) ===
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- === Submap de redimensionamento via teclado ===
hl.bind(mainMod .. " + R", hl.dsp.submap("resize"))
hl.define_submap("resize", function()
	hl.bind("l", hl.dsp.window.resize({ x = 30, y = 0, relative = true }), { repeating = true })
	hl.bind("h", hl.dsp.window.resize({ x = -30, y = 0, relative = true }), { repeating = true })
	hl.bind("k", hl.dsp.window.resize({ x = 0, y = -30, relative = true }), { repeating = true })
	hl.bind("j", hl.dsp.window.resize({ x = 0, y = 30, relative = true }), { repeating = true })
	hl.bind("escape", hl.dsp.submap("reset"))
end)
