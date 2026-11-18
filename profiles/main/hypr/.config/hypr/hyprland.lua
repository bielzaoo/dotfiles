-- Entrada do Hyprland: só carrega os módulos.
-- Tudo em ~/.config/hypr/ é específico do compositor (lado wm/).
-- O que vale pra qualquer compositor Wayland mora em ~/.config/session/
-- e nos configs de cada app (waybar, mako, kitty...): esse é o seam.
-- Docs: https://wiki.hypr.land/Configuring/Start/

require("monitors")
require("env")
require("look")
require("cor-atual")     -- gerado pelo repinta (bordas da paleta/modo ativo)
require("espaco-atual")  -- symlink -> espacos/*.lua (gaps do Terminal Mode)
require("forma-atual")   -- gerado pelo repinta (forma do modo; ganha do espaco)
require("input")
require("binds")
require("rules")
require("paineis-atual") -- gerado pelo repinta (painéis TUI por modo; ganha do rules)
require("flutuante")     -- SUPER+ALT+V: modo flutuante; Alt+Tab
require("autostart")
