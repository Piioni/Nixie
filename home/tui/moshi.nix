{ config, pkgs, ... }:
{
  home.packages = [ pkgs.moshi ];

  xdg.configFile."moshi/config.toml".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/home/tui/moshi/config.toml";
}
