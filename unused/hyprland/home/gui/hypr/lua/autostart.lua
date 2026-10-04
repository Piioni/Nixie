-- Start Noctalia once for the selected Hyprland session.
hl.on("hyprland.start", function()
  hl.exec_cmd("noctalia")
  hl.exec_cmd("wl-paste --type text --watch cliphist store")
  hl.exec_cmd("wl-paste --type image --watch cliphist store")
  hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")
end)
