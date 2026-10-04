{ config, pkgs, ... }:
{
  home.packages = [
    pkgs.hyprland
    pkgs.hyprpicker
    pkgs.wf-recorder
  ];

  # Hyprland is fully live: Nix only creates the links, so every Lua file and
  # script is edited in the checkout and takes effect on reload.
  xdg.configFile = {
    "hypr/hyprland.lua".source =
      config.lib.file.mkOutOfStoreSymlink "${config.nixie.home.repositoryRoot}/home/gui/hypr/hyprland.lua";
    "hypr/lua".source =
      config.lib.file.mkOutOfStoreSymlink "${config.nixie.home.repositoryRoot}/home/gui/hypr/lua";
    "hypr/scripts".source =
      config.lib.file.mkOutOfStoreSymlink "${config.nixie.home.repositoryRoot}/home/gui/hypr/scripts";
  };
}
