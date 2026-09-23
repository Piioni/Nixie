{ username, ... }:
{
  imports = [
    ./agents
    ./core
    ./gui
  ];

  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;
}
