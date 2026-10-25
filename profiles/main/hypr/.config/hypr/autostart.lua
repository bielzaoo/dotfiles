-------------------
---- AUTOSTART ----
-------------------

-- Lado wm/: só o que depende do Hyprland. O resto vem do script agnóstico.
hl.on("hyprland.start", function()
    hl.exec_cmd("~/.config/session/autostart.sh")
    hl.exec_cmd("hypridle")
end)
