{ pkgs, ... }:
{
  home.packages = [ pkgs.tuxedo-rs ];

  xdg.configFile."tuxedo/config.toml".source = ./tuxedo/config.toml;
}
