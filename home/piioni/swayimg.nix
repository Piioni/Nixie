{ pkgs, ... }:
{
  home.packages = [ pkgs.swayimg ];

  xdg.configFile."swayimg/init.lua".source = ./swayimg/init.lua;
}
