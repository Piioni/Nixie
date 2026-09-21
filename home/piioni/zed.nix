{ pkgs, ... }:
{
  home.packages = [ pkgs.zed-editor ];

  xdg.configFile = {
    # Zed configuration is JSONC (comments plus trailing commas). The repository
    # file keeps its true extension; the target keeps the name Zed requires.
    "zed/settings.json".source = ./zed/settings.jsonc;
    "zed/keymap.json".source = ./zed/keymap.json;
  };
}
