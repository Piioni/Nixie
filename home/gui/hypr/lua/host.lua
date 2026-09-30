-- Resolves this machine's facts from lua/hosts/<hostname>.lua so the shared
-- configuration stays identical on both machines.
local fallback = {
  touchpad = false,
  brightnessKeys = false,
}

local function hostname()
  local file = io.open("/etc/hostname", "r")
  if not file then
    return nil
  end

  local name = file:read("*l")
  file:close()
  return name
end

local name = hostname()
if not name or name == "" then
  io.stderr:write("nixie: /etc/hostname is unreadable; using default Hyprland facts\n")
  return fallback
end

local ok, host = pcall(require, "lua.hosts." .. name)
if not ok then
  io.stderr:write("nixie: no Hyprland facts at lua/hosts/" .. name .. ".lua; using defaults\n")
  return fallback
end

return host
