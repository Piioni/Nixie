{
  config,
  nixGaming,
  lib,
  ...
}:
let
  cfg = config.modules.gaming;
in
{
  imports = [
    nixGaming.nixosModules.pipewireLowLatency
    nixGaming.nixosModules.platformOptimizations
  ];

  options.modules.gaming = {
    enable = lib.mkEnableOption "the shared gaming stack";

    steamGamescopeSession = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the Gamescope Steam session.";
    };

    steamProtontricks = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Protontricks integration for Steam.";
    };

    steamExtest = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Steam extest for Steam Input on Wayland.";
    };

    nonSteamTools = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Install non-Steam gaming tools through Home Manager.";
    };

    launchers = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Install non-Steam launchers through Home Manager.";
    };

    mangoHud = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Install MangoHud through Home Manager.";
    };

    lowLatencyPipeWire = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable nix-gaming low-latency PipeWire settings.";
    };

    platformOptimizations = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable nix-gaming Steam platform optimizations.";
    };
  };

  config = {
    programs.steam = {
      enable = cfg.enable;
      gamescopeSession.enable = cfg.enable && cfg.steamGamescopeSession;
      protontricks.enable = cfg.enable && cfg.steamProtontricks;
      extest.enable = cfg.enable && cfg.steamExtest;
      platformOptimizations.enable = cfg.enable && cfg.platformOptimizations;
    };

    programs.gamemode.enable = cfg.enable;
    services.pipewire.lowLatency.enable = cfg.enable && cfg.lowLatencyPipeWire;
  };
}
