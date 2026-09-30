{ noctalia, ... }:
{
  imports = [
    noctalia.homeModules.default
    ./browsers.nix
    ./desktop-tools.nix
    ./ghostty.nix
    ./gtk.nix
    ./hypr.nix
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
