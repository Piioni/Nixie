{ pkgs, config, ... }:
{
  home.packages = [
    pkgs.hyprland
    pkgs.hyprpicker
    pkgs.wf-recorder
  ];

  xdg.configFile = {
    "hypr/hyprland.lua".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/home/gui/hypr/hyprland.lua";

    # WU3b replaces this recursive owner with direct and rendered leaf targets.
    "hypr/lua" = {
      source = ./hypr/lua;
      recursive = true;
    };

    "hypr/scripts/colorpicker.sh".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/home/gui/hypr/scripts/colorpicker.sh";
    "hypr/scripts/helium-clean-singletons.sh".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/home/gui/hypr/scripts/helium-clean-singletons.sh";
    "hypr/scripts/logout.sh".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/home/gui/hypr/scripts/logout.sh";
    "hypr/scripts/record.sh".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/home/gui/hypr/scripts/record.sh";
  };
}
