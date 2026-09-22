{ config, pkgs, ... }:
{
  home.packages = [ pkgs.swappy ];

  xdg.configFile."swappy/config".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/home/piioni/swappy/config";
}
