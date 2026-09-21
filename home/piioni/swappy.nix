{ pkgs, ... }:
{
  home.packages = [ pkgs.swappy ];

  xdg.configFile."swappy/config".source = ./swappy/config;
}
