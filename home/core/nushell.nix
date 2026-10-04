{ config, lib, ... }:
let
  toNu = lib.hm.nushell.toNushell { };
  expandHome =
    builtins.replaceStrings
      [ "$HOME" "\${HOME}" ]
      [
        config.home.homeDirectory
        config.home.homeDirectory
      ];
in
{
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    TERMINAL = "ghostty";
    BROWSER = "helium";
  };

  programs.nushell = {
    enable = true;
    configFile.source = ./nushell/config.nu;
    envFile.source = ./nushell/env.nu;
    # Nushell is the login shell, so it must load what hm-session-vars.sh gives POSIX shells.
    extraEnv = ''
      load-env ${toNu config.home.sessionVariables}
      let nixPaths = ${
        toNu [
          "/run/wrappers/bin"
          "${config.home.profileDirectory}/bin"
          "/run/current-system/sw/bin"
        ]
      }
      let sessionPaths = ${toNu (map expandHome config.home.sessionPath)}
      $env.PATH = (($nixPaths ++ ($env.PATH? | default []) ++ $sessionPaths) | uniq)
    '';
  };

  xdg.configFile = {
    "nushell/autoload/20-interface.nu".source = ./nushell/autoload/20-interface.nu;
    "nushell/autoload/30-colors.nu".source = ./nushell/autoload/30-colors.nu;
    "nushell/autoload/40-prompt.nu".source = ./nushell/autoload/40-prompt.nu;
    "nushell/autoload/50-aliases.nu".source = ./nushell/autoload/50-aliases.nu;
    "nushell/autoload/60-functions.nu".source = ./nushell/autoload/60-functions.nu;
  };
}
