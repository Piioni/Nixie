{ config, ... }:
{
  programs.nushell = {
    enable = true;
    configFile.source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/home/core/nushell/config.nu";
    envFile.source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/home/core/nushell/env.nu";
  };

  xdg.configFile = {
    "nushell/autoload/20-interface.nu".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/home/core/nushell/autoload/20-interface.nu";
    "nushell/autoload/30-colors.nu".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/home/core/nushell/autoload/30-colors.nu";
    "nushell/autoload/40-prompt.nu".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/home/core/nushell/autoload/40-prompt.nu";
    "nushell/autoload/50-aliases.nu".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/home/core/nushell/autoload/50-aliases.nu";
    "nushell/autoload/60-functions.nu".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/home/core/nushell/autoload/60-functions.nu";
  };
}
