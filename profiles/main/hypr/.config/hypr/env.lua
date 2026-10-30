-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- greetd não lê o ~/.bashrc: sem isso binds/autostart não acham ~/.local/bin (vicinae, fonte, cor, espaco)
local localBin = os.getenv("HOME") .. "/.local/bin"
if not (":" .. os.getenv("PATH") .. ":"):find(":" .. localBin .. ":", 1, true) then
    hl.env("PATH", localBin .. ":" .. os.getenv("PATH"))  -- guarda: reload não duplica
end

-- Idem pro ssh-agent (o environment.d só chega no systemd --user): sem isso app
-- aberto pelo launcher (Obsidian Git) não acha o agente e pede a senha da chave
hl.env("SSH_AUTH_SOCK", os.getenv("XDG_RUNTIME_DIR") .. "/ssh-agent.socket")


-----------------------
----- PERMISSIONS -----
-----------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Permissions/
-- Please note permission changes here require a Hyprland restart and are not applied on-the-fly
-- for security reasons

-- hl.config({
--   ecosystem = {
--     enforce_permissions = true,
--   },
-- })

-- hl.permission("/usr/(bin|local/bin)/grim", "screencopy", "allow")
-- hl.permission("/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland", "screencopy", "allow")
-- hl.permission("/usr/(bin|local/bin)/hyprpm", "plugin", "allow")
