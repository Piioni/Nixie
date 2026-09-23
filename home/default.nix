{ ... }:
{
  imports = [
    ./core
    ./tui
    ./gui
  ];

  home.username = "piioni";
  home.homeDirectory = "/home/piioni";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;
}
