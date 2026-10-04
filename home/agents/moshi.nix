{ config, pkgs, ... }:
let
  tomlFormat = pkgs.formats.toml { };
  moshiHook = pkgs.callPackage ../../packages/moshi-hook.nix { };
in
{
  home.packages = [ moshiHook ];

  home.file.".local/bin/moshi-hook".source = "${moshiHook}/bin/moshi-hook";

  xdg.configFile."moshi/config.toml".source = tomlFormat.generate "moshi-config.toml" {
    gateway = {
      always_on_discovery = false;
      usage_collection = false;
      scan_ports = [ ];
    };
  };

  systemd.user.services.moshi-hook = {
    Unit = {
      Description = "Moshi Hook local agent integration service";
    };

    Service = {
      ExecStart = "${moshiHook}/bin/moshi-hook serve";
      Restart = "on-failure";
      RestartSec = "5s";
      WorkingDirectory = config.home.homeDirectory;
      Environment = "PATH=/run/wrappers/bin:${config.home.profileDirectory}/bin:/run/current-system/sw/bin";
    };

    Install.WantedBy = [ "default.target" ];
  };
}
