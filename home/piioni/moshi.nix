{ pkgs, ... }:
{
  home.packages = [ pkgs.moshi ];

  xdg.configFile."moshi/config.toml".source = ./moshi/config.toml;
}
