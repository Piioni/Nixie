{ noctalia, ... }:
{
  imports = [
    noctalia.homeModules.default
    ./browsers.nix
    ./desktop-tools.nix
    ./desktop-apps.nix
    ./ghostty.nix
    ./gtk.nix
    ./kitty.nix
    ./media.nix
    ./misc.nix
    ./nautilus.nix
    ./niri.nix
    ./noctalia.nix
    ./stylix.nix
    ./xdg-apps.nix
    ./zed.nix
  ];
}
