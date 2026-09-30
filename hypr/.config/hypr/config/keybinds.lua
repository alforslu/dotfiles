return function(programs)
    -- See https://wiki.hyprland.org/Configuring/Keywords/
    local mainMod = "SUPER"

    -- Main binds

    hl.bind(mainMod .. " + " .. "return", hl.dsp.exec_cmd(programs.terminal))
    hl.bind(mainMod .. " + " .. "SPACE", hl.dsp.exec_cmd(programs.menu))
    hl.bind(mainMod .. " + " .. "Q", hl.dsp.window.close())
    hl.bind(mainMod .. " + " .. "D", hl.dsp.exec_cmd(programs.fileManager))
    hl.bind(mainMod .. " + " .. "E", hl.dsp.exec_cmd(programs.browser))
    hl.bind(mainMod .. " + " .. "escape", hl.dsp.exec_cmd(programs.powerctl)) -- NOTE: Broken due to rework
    hl.bind(mainMod .. " + " .. "F", hl.dsp.window.float())
    hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "F", hl.dsp.window.fullscreen())

    -- Screenshots
    hl.bind("PRINT", hl.dsp.exec_cmd("hyprshot -m window"))
    hl.bind("CONTROL + PRINT", hl.dsp.exec_cmd("hyprshot -m region"))
    hl.bind("SUPER + SHIFT + L", hl.dsp.exec_cmd("hyprlock"))

    -- Move focus with mainMod + arrow keys
    hl.bind(mainMod .. " + " .. "H", hl.dsp.focus({ direction = "left" }))
    hl.bind(mainMod .. " + " .. "L", hl.dsp.focus({ direction = "right" }))
    hl.bind(mainMod .. " + " .. "K", hl.dsp.focus({ direction = "up" }))
    hl.bind(mainMod .. " + " .. "J", hl.dsp.focus({ direction = "down" }))

    -- Resize windows with super + arrow keys
    hl.bind(mainMod .. " + " .. "right", hl.dsp.window.resize({ x = 40, y = 0, relative = true }))
    hl.bind(mainMod .. " + " .. "left", hl.dsp.window.resize({ x = -40, y = 0, relative = true }))
    hl.bind(mainMod .. " + " .. "up", hl.dsp.window.resize({ x = 0, y = -40, relative = true }))
    hl.bind(mainMod .. " + " .. "down", hl.dsp.window.resize({ x = 0, y = 40, relative = true }))

    -- Switch workspaces with mainMod + [0-9]
    hl.bind(mainMod .. " + " .. 1, hl.dsp.focus({ workspace = 1 }))
    hl.bind(mainMod .. " + " .. 2, hl.dsp.focus({ workspace = 2 }))
    hl.bind(mainMod .. " + " .. 3, hl.dsp.focus({ workspace = 3 }))
    hl.bind(mainMod .. " + " .. 4, hl.dsp.focus({ workspace = 4 }))
    hl.bind(mainMod .. " + " .. 5, hl.dsp.focus({ workspace = 5 }))
    hl.bind(mainMod .. " + " .. 6, hl.dsp.focus({ workspace = 6 }))
    hl.bind(mainMod .. " + " .. 7, hl.dsp.focus({ workspace = 7 }))
    hl.bind(mainMod .. " + " .. 8, hl.dsp.focus({ workspace = 8 }))
    hl.bind(mainMod .. " + " .. 9, hl.dsp.focus({ workspace = 9 }))
    hl.bind(mainMod .. " + " .. 0, hl.dsp.focus({ workspace = 10 }))

    -- Move active window to a workspace with mainMod + SHIFT + [0-9]
    hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. 1, hl.dsp.window.move({ workspace = 1 }))
    hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. 2, hl.dsp.window.move({ workspace = 2 }))
    hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. 3, hl.dsp.window.move({ workspace = 3 }))
    hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. 4, hl.dsp.window.move({ workspace = 4 }))
    hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. 5, hl.dsp.window.move({ workspace = 5 }))
    hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. 6, hl.dsp.window.move({ workspace = 6 }))
    hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. 7, hl.dsp.window.move({ workspace = 7 }))
    hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. 8, hl.dsp.window.move({ workspace = 8 }))
    hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. 9, hl.dsp.window.move({ workspace = 9 }))
    hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. 0, hl.dsp.window.move({ workspace = 10 }))

    -- Show/hide scratchpad
    hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))

    -- Send focused window to scratchpad
    hl.bind(
        mainMod .. " + SHIFT + S",
        hl.dsp.window.move({
            workspace = "special:magic",
            follow = false,
        })
    )

    -- Move/resize windows with mainMod + LMB/RMB and dragging
    hl.bind(mainMod .. " + " .. "mouse:272", hl.dsp.window.drag(), { mouse = true })
    hl.bind(mainMod .. " + " .. "mouse:273", hl.dsp.window.resize(), { mouse = true })

    -- Laptop multimedia keys for volume and LCD brightness
    hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("swayosd-client --output-volume raise"), { locked = true })
    hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("swayosd-client --output-volume lower"), { locked = true })
    hl.bind("XF86AudioMute", hl.dsp.exec_cmd("swayosd-client --output-volume mute-toggle"), { locked = true })
    hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })

    -- NOTE: Below might be broken, can't test atm
    hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("swayosd-client --input-volume mute-toggle"))
    hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("swayosd-client --brightness raise"), { locked = true })
    hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("swayosd-client --brightness lower"), { locked = true })

    -- Backlight
    hl.bind(
        "XF86KbdBrightnessDown",
        hl.dsp.exec_cmd("swayosd-client --brightness lower --device tpacpi::kbd_backlight"),
        { locked = true }
    )
    hl.bind(
        "XF86KbdBrightnessUp",
        hl.dsp.exec_cmd("swayosd-client --brightness raise --device tpacpi::kbd_backlight"),
        { locked = true }
    )

    -- Requires playerctl
    hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
    hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
    hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
    hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
end
