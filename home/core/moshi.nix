{ config, pkgs, ... }:
{
  home.packages = [ pkgs.moshi ];

  xdg.configFile."moshi/config.toml".source =
    config.lib.file.mkOutOfStoreSymlink "${config.nixie.home.repositoryRoot}/home/core/moshi/config.toml";
}
