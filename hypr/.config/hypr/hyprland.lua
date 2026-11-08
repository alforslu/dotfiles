---@module 'hl'

--######################
--## CUSTOM PROGRAMS ###
--######################

local terminal = "kitty"
local fileManager = "thunar"
local browser = "firefox"

-- TODO: Replace wleave and wofi with quickshell
local powerctl = "wleave -l ~/.config/wlogout/config.json"
local menu = "wofi --show drun"

--#####################
--## CONFIG IMPORTS ###
--#####################

-- Only import if existing
for _, name in ipairs({ "monitors", "workspaces" }) do
    if package.searchpath(name, package.path) then
        require(name)
    end
end

require("config.style")
require("config.keybinds")({
    terminal = terminal,
    fileManager = fileManager,
    browser = browser,
    powerctl = powerctl,
    menu = menu,
})

--################
--## AUTOSTART ###
--################

hl.on("hyprland.start", function()
    hl.exec_cmd("qs & swaync & hypridle & hyprpaper & swayosd-server")
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
    hl.exec_cmd("hyprctl dispatch workspace 1")
    -- hl.exec_cmd("hyprpm reload -nn")
end)

--############################
--## ENVIRONMENT VARIABLES ###
--############################

-- See https://wiki.hyprland.org/Configuring/Environment-variables/

hl.env("XCURSOR_SIZE", 24)
hl.env("HYPRCURSOR_SIZE", 24)

--##############
--## Plugins ###
--##############

-- Empty

--############
--## INPUT ###
--############

-- https://wiki.hyprland.org/Configuring/Variables/#input

hl.config({
    input = {
        kb_layout = "se",
        kb_options = "caps:escape",
        accel_profile = "flat",
        follow_mouse = 1,
        force_no_accel = true,
    },
})

-- https://wiki.hyprland.org/Configuring/Variables/#gestures

--#############################
--## WINDOWS AND WORKSPACES ###
--#############################

-- See https://wiki.hyprland.org/Configuring/Window-Rules/ for more
-- See https://wiki.hyprland.org/Configuring/Workspace-Rules/ for workspace rules

-- Ignore maximize requests from apps
hl.window_rule({
    match = { class = ".*" },
    suppress_event = "maximize",
})

-- Fix some dragging issues with XWayland
hl.window_rule({
    match = {
        class = "^$",
        title = "^$",
        xwayland = true,
        float = true,
        fullscreen = false,
        pin = false,
    },
    no_focus = true,
})

require("machine")
