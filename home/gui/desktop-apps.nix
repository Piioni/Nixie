{ pkgs, ... }:
{
  home.packages = with pkgs; [
    vesktop
    tidal-hifi
    signal-desktop
    teams-for-linux
    figma-linux
  ];
}
