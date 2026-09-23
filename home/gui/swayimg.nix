{ config, pkgs, ... }:
{
  home.packages = [ pkgs.swayimg ];

  xdg.configFile."swayimg/init.lua".source =
    config.lib.file.mkOutOfStoreSymlink "${config.nixie.home.repositoryRoot}/home/gui/swayimg/init.lua";
}
