{ ... }:
{
  programs.nushell = {
    enable = true;
    configFile.source = ./nushell/config.nu;
    envFile.source = ./nushell/env.nu;
  };

  programs.zoxide = {
    enable = true;
    enableNushellIntegration = true;
  };

  xdg.configFile = {
    "nushell/autoload/20-interface.nu".source = ./nushell/autoload/20-interface.nu;
    "nushell/autoload/30-colors.nu".source = ./nushell/autoload/30-colors.nu;
    "nushell/autoload/40-prompt.nu".source = ./nushell/autoload/40-prompt.nu;
    "nushell/autoload/50-aliases.nu".source = ./nushell/autoload/50-aliases.nu;
    "nushell/autoload/60-functions.nu".source = ./nushell/autoload/60-functions.nu;
  };
}
