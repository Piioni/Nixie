{ config, pkgs, ... }:
{
  home.packages = [ pkgs.zed-editor ];

  xdg.configFile = {
    # Zed configuration is JSONC (comments plus trailing commas). The repository
    # file keeps its true extension; the target keeps the name Zed requires.
    "zed/settings.json".text =
      builtins.replaceStrings
        [ "/home/piioni/fvm/versions/3.24.2/bin/dart" ]
        [ "${config.home.homeDirectory}/fvm/versions/3.24.2/bin/dart" ]
        (builtins.readFile ./zed/settings.jsonc);
    "zed/keymap.json".source = ./zed/keymap.json;
  };
}
