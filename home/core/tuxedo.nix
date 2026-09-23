{ config, pkgs, ... }:
{
  home.packages = [ pkgs.tuxedo-rs ];

  xdg.configFile."tuxedo/config.toml".source =
    config.lib.file.mkOutOfStoreSymlink "${config.nixie.home.repositoryRoot}/home/core/tuxedo/config.toml";
}
