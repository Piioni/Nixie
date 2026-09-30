-- Laptop display facts: internal panel plus an external HDMI output, with
-- workspaces pinned per monitor.
hl.monitor({
  output = "eDP-1",
  mode = "1920x1080@60",
  position = "0x0",
  scale = 1,
})

hl.monitor({
  output = "HDMI-A-1",
  mode = "1920x1080@120",
  position = "1920x0",
  scale = 1,
})

local function pin(monitor, workspaces)
  if hl.get_monitor(monitor) == nil then
    return
  end

  for _, workspace in ipairs(workspaces) do
    hl.workspace_rule({
      workspace = workspace,
      monitor = monitor,
      default = true,
      persistent = true,
    })
  end
end

pin("HDMI-A-1", { "1", "2", "3", "4" })
pin("eDP-1", { "5", "6" })

return {
  touchpad = true,
  brightnessKeys = true,
}
