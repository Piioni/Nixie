{ pkgs, ... }:
{
  home.packages = [ pkgs.hyprland ];

  xdg.configFile = {
    "hypr/hyprland.lua".source = ./hypr/hyprland.lua;

    "hypr/lua" = {
      source = ./hypr/lua;
      recursive = true;
    };

    "hypr/scripts" = {
      source = ./hypr/scripts;
      recursive = true;
    };
  };
}
