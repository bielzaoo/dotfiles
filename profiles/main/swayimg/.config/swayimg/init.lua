-- swayimg: só o que muda dos defaults embutidos (/usr/share/swayimg/example.lua
-- é a referência completa). Cores e fonte vêm do tema-atual.lua, que o repinta
-- gera da paleta do kitty; sem ele, fica o default.
local ok, tema = pcall(dofile, os.getenv("HOME") .. "/.config/swayimg/tema-atual.lua")

swayimg.decoration = false -- o Hyprland já desenha a borda

if ok then
  swayimg.text.font = tema.font
  swayimg.text.size = tema.size
  swayimg.text.color = tema.fg
  swayimg.text.shadow = tema.bg
  swayimg.viewer.mark_color = tema.ok
  swayimg.viewer.set_window_background(tema.bg)
  swayimg.viewer.set_image_chessboard(20, tema.bg, tema.mix) -- fundo de PNG transparente
  swayimg.gallery.border_color = tema.ativo
  swayimg.gallery.selected_color = tema.mix
  swayimg.gallery.unselected_color = tema.bg
  swayimg.gallery.window_color = tema.bg
end
