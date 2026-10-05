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
    # Trash, network shares and MTP phones in Nautilus.
    gvfs.enable = true;
    xserver.xkb.layout = "us";
  };
}
