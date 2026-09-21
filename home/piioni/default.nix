{ ... }:
{
  imports = [
    ./agents.nix
    ./btop.nix
    ./caelestia.nix
    ./fastfetch.nix
    ./ghostty.nix
    ./herdr.nix
    ./hypr.nix
    ./kitty.nix
    ./lazygit.nix
    ./moshi.nix
    ./nushell.nix
    ./packages.nix
    ./starship.nix
    ./swappy.nix
    ./swayimg.nix
    ./swaync.nix
    ./tuxedo.nix
    ./yazi.nix
    ./zed.nix
    ./zellij.nix
  ];

  home.username = "piioni";
  home.homeDirectory = "/home/piioni";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;
}
