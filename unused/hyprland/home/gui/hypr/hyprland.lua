-- Main Hyprland entrypoint for the live configuration.
-- The host file is the only machine-specific input; everything else is shared.
require("lua.host")

require("lua.programs")
require("lua.decorations")
require("lua.animations")
require("lua.inputs")
require("lua.settings")
require("lua.gestures")
require("lua.keybinds")
require("lua.windowrules")
require("lua.workspaces")
require("lua.autostart")
