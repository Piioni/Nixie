{ config, ... }:
{
  programs.nushell = {
    enable = true;
    configFile.source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/home/tui/nushell/config.nu";
    envFile.source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/home/tui/nushell/env.nu";
  };

  programs.zoxide = {
    enable = true;
    enableNushellIntegration = true;
  };

  xdg.configFile = {
    "nushell/autoload/20-interface.nu".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/home/tui/nushell/autoload/20-interface.nu";
    "nushell/autoload/30-colors.nu".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/home/tui/nushell/autoload/30-colors.nu";
    "nushell/autoload/40-prompt.nu".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/home/tui/nushell/autoload/40-prompt.nu";
    "nushell/autoload/50-aliases.nu".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/home/tui/nushell/autoload/50-aliases.nu";
    "nushell/autoload/60-functions.nu".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/home/tui/nushell/autoload/60-functions.nu";
  };
}
