{ pkgs, config, ... }:
{
  home.packages = [ pkgs.btop ];

  xdg.configFile = {
    # WU3b renders this target from the battery fact.
    "btop/btop.conf".source = ./btop/btop.conf;
    "btop/themes/catppuccin_macchiato.theme".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/home/tui/btop/themes/catppuccin_macchiato.theme";
    "btop/themes/catppuccin_mocha.theme".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/home/tui/btop/themes/catppuccin_mocha.theme";
    "btop/themes/caelestia.theme".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/home/tui/btop/themes/caelestia.theme";
  };
}
