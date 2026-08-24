hl.config({
	general = {
		gaps_in = 4,
		gaps_out = 8,
		border_size = 2,
		["col.active_border"] = "rgba(00f0ffee)",
		["col.inactive_border"] = "rgba(0090a0aa)",
		layout = "dwindle",
	},
	decoration = {
		rounding = 8,
		active_opacity = 1.0,
		inactive_opacity = 0.95,
		blur = { enabled = true, size = 2, passes = 1 },
		shadow = {
			enabled = true,
			range = 12,
			render_power = 3,
			color = "rgba(00f0ff55)",
		},
	},
	dwindle = {
		preserve_split = true,
	},
	misc = {
		disable_hyprland_logo = true,
	},
	debug = {
		vfr = true,
	},
})
-- Curvas de animação
hl.curve("myBezier", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })
-- Animações por elemento (bezier é obrigatório em toda chamada)
hl.animation({ leaf = "windows", enabled = true, speed = 4, bezier = "myBezier" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 4, bezier = "myBezier", style = "popin 80%" })
hl.animation({ leaf = "border", enabled = true, speed = 6, bezier = "myBezier" })
hl.animation({ leaf = "fade", enabled = true, speed = 4, bezier = "myBezier" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 4, bezier = "myBezier" })
hl.window_rule({ match = { class = "^(wiremix)$" }, float = true, size = { 600, 400 } })
hl.window_rule({ match = { class = "^(wlctl)$" }, float = true, size = { 600, 400 } })
hl.window_rule({ match = { class = "^(bluetui)$" }, float = true, size = { 600, 400 } })
hl.window_rule({ match = { class = "^(btop)$" }, float = true, size = { 800, 550 } })
hl.window_rule({ match = { class = "^(lazygit)$" }, float = true, size = { 900, 600 } })
hl.window_rule({ match = { class = "^(yazi)$" }, float = true, size = { 900, 600 } })
