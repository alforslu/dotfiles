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

require("monitors")
require("workspaces")
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
    hl.exec_cmd("waybar & swaync & hypridle & hyprpaper & swayosd-server")
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
    hl.exec_cmd("hyperctl dispatch workspace 1")
    -- hl.exec_cmd("hyprpm reload -nn")
end)

--############################
--## ENVIRONMENT VARIABLES ###
--############################

-- See https://wiki.hyprland.org/Configuring/Environment-variables/

hl.env("XCURSOR_SIZE", 24)
hl.env("HYPRCURSOR_SIZE", 24)
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")

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
        -- sensitivity = 0.2,
        -- -1.0 - 1.0, 0 means no modification.
        touchpad = {
            natural_scroll = false,
        },
    },
})

-- https://wiki.hyprland.org/Configuring/Variables/#gestures

-- Example per-device config
-- See https://wiki.hyprland.org/Configuring/Keywords/#per-device-input-configs for more
hl.device({
    name = "epic-mouse-v1",
    sensitivity = -0.5,
})


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
