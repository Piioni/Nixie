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

        -- @GENERATED_TOUCHPAD_CONFIG@
    },
})
