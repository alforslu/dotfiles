hl.monitor({
    output = "eDP-1",
    mode = "1920x1080@60.0",
    position = "0x0",
    scale = 1.25,
})

hl.config({
    input = {
        sensitivity = 0.2,
        touchpad = {
            natural_scroll = true,
            clickfinger_behavior = true,
            disable_while_typing = true,
        },
    },
    xwayland = {
        force_zero_scaling = true,
    },
})

hl.bind("XF86Display", hl.dsp.exec_cmd("wdisplays"), { locked = true })

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
