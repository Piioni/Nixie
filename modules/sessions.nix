{ ... }:
{
  programs = {
    hyprland.enable = true;
    niri.enable = true;
  };

  services = {
    displayManager = {
      sddm = {
        enable = true;
        wayland.enable = true;
      };
    };
    greetd.enable = false;
    xserver.xkb.layout = "us";
  };
}
