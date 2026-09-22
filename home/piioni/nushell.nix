{ config, ... }:
{
  programs.nushell = {
    enable = true;
    configFile.source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/home/piioni/nushell/config.nu";
    envFile.source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/home/piioni/nushell/env.nu";
  };

  programs.zoxide = {
    enable = true;
    enableNushellIntegration = true;
  };

  xdg.configFile = {
    "nushell/autoload/20-interface.nu".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/home/piioni/nushell/autoload/20-interface.nu";
    "nushell/autoload/30-colors.nu".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/home/piioni/nushell/autoload/30-colors.nu";
    "nushell/autoload/40-prompt.nu".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/home/piioni/nushell/autoload/40-prompt.nu";
    "nushell/autoload/50-aliases.nu".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/home/piioni/nushell/autoload/50-aliases.nu";
    "nushell/autoload/60-functions.nu".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/home/piioni/nushell/autoload/60-functions.nu";
  };
}
