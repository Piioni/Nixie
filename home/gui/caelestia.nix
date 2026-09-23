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
      config.lib.file.mkOutOfStoreSymlink "${config.nixie.home.repositoryRoot}/home/gui/caelestia/cli.json";

    "caelestia/shell.json".text =
      lib.replaceStrings [ "@HYPR_LOGOUT_SCRIPT@" ] [ "${config.xdg.configHome}/hypr/scripts/logout.sh" ]
        (builtins.readFile ./caelestia/shell.json);
  };
}
