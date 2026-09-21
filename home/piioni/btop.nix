{ pkgs, ... }:
{
  home.packages = [ pkgs.btop ];

  xdg.configFile = {
    "btop/btop.conf".source = ./btop/btop.conf;
    "btop/themes/catppuccin_macchiato.theme".source = ./btop/themes/catppuccin_macchiato.theme;
    "btop/themes/catppuccin_mocha.theme".source = ./btop/themes/catppuccin_mocha.theme;
    "btop/themes/caelestia.theme".source = ./btop/themes/caelestia.theme;
  };
}
