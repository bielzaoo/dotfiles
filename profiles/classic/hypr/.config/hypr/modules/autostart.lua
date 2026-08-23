hl.on("hyprland.start", function()
    -- hl.exec_cmd("waybar")
    hl.exec_cmd("quickshell")
    -- hl.exec_cmd("mako")       -- notificações (substituído por Quickshell)
    hl.exec_cmd("hyprpaper")  -- wallpaper
    hl.exec_cmd("wl-paste --watch cliphist store")
    hl.exec_cmd("hypridle")
end)
