{ config, pkgs, ... }:
{
  home.packages = [ pkgs.tuxedo-rs ];

  xdg.configFile."tuxedo/config.toml".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/home/tui/tuxedo/config.toml";
}
