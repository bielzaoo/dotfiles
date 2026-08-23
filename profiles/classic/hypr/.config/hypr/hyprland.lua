-- Arquivo principal: apenas orquestra os módulos
package.path = package.path .. ";" .. os.getenv("HOME") .. "/.config/hypr/modules/?.lua"

require("environment")
require("programs")
require("monitors")
require("input")
require("appearance")
require("keybinds")
require("autostart")
