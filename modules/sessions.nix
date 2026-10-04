{ ... }:
{
  programs.niri.enable = true;

  security.pam.services.sddm.enableGnomeKeyring = true;

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
