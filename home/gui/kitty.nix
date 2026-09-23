{ pkgs, lib, ... }:
{
  home.packages = [ pkgs.kitty ];

  xdg.configFile = {
    # Kitty must not launch Fish; it launches the declarative Nushell path.
    "kitty/kitty.conf".text = lib.replaceStrings [ "fish\n" ] [ "${pkgs.nushell}/bin/nu\n" ] (
      builtins.readFile ./kitty/kitty.conf
    );

    "kitty/Catppuccin-Mocha.conf".source = ./kitty/Catppuccin-Mocha.conf;

    "kitty/utils/scroll_mark.py".source = ./kitty/utils/scroll_mark.py;
    "kitty/utils/search.py".source = ./kitty/utils/search.py;
  };
}
