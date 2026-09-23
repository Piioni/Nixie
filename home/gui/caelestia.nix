{
  pkgs,
  lib,
  config,
  ...
}:
{
  home.packages = [
    pkgs.caelestia-cli
    pkgs.caelestia-shell
  ];

  xdg.configFile = {
    "caelestia/cli.json".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/home/gui/caelestia/cli.json";

    "caelestia/shell.json".text =
      lib.replaceStrings
        [ "/home/piioni/.config/hypr/scripts/logout.sh" ]
        [ "${config.xdg.configHome}/hypr/scripts/logout.sh" ]
        (builtins.readFile ./caelestia/shell.json);
  };
}
