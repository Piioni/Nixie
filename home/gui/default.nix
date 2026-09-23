{ noctalia, ... }:
{
  imports = [
    noctalia.homeModules.default
    ./ghostty.nix
    ./helium.nix
    ./hypr.nix
    ./kitty.nix
    ./niri.nix
    ./noctalia.nix
    ./swappy.nix
    ./swayimg.nix
    ./zed.nix
  ];
}
