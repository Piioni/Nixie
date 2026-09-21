{
  pkgs,
  lib,
  config,
  ...
}:
{
  home.packages = [ pkgs.swaynotificationcenter ];

  xdg.configFile = {
    "swaync/config.json".text =
      lib.replaceStrings
        [ "/home/piioni/.config/hypr/scripts/logout.sh" ]
        [ "${config.xdg.configHome}/hypr/scripts/logout.sh" ]
        (builtins.readFile ./swaync/config.json);

    "swaync/style.css".source = ./swaync/style.css;

    "swaync/icons" = {
      source = ./swaync/icons;
      recursive = true;
    };
  };
}
