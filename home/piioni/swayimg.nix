{ config, pkgs, ... }:
{
  home.packages = [ pkgs.swayimg ];

  xdg.configFile."swayimg/init.lua".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/home/piioni/swayimg/init.lua";
}
