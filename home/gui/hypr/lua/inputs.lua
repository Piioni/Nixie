local host = require("lua.host")

-- Touchpad preferences only apply on machines that have a touchpad.
local touchpad = host.touchpad and {
    -- Tapping is on, but drag lock is off to avoid sticky drags.
    tap_to_click = true,
    disable_while_typing = true,
    natural_scroll = true,
    clickfinger_behavior = true,
} or nil

-- Core keyboard and touchpad behavior preferences.
hl.config({
    input = {
        -- Keyboard
        kb_layout = "us",
        repeat_rate = 50,
        repeat_delay = 300,
        numlock_by_default = true,

        -- Mouse
        sensitivity = 0.1,
        accel_profile = "flat",
        left_handed = false,
        follow_mouse = true,
        float_switch_override_focus = false,

        touchpad = touchpad,
    },
})
