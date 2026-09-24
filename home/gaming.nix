{
  pkgs,
  osConfig,
  lib,
  ...
}:
let
  cfg = osConfig.modules.gaming;
in
{
  config = lib.mkIf cfg.enable {
    home.packages =
      lib.optionals cfg.mangoHud [ pkgs.mangohud ]
      ++ lib.optionals cfg.nonSteamTools [
        pkgs.protonplus
        pkgs.winetricks
        pkgs.umu-launcher
        pkgs.proton-ge-bin.steamcompattool
      ]
      ++ lib.optionals cfg.launchers [ pkgs.heroic ];

    programs.lutris = lib.mkIf cfg.launchers {
      enable = true;
      defaultWinePackage = pkgs.proton-ge-bin;
      steamPackage = osConfig.programs.steam.package;
      protonPackages = [ pkgs.proton-ge-bin ];
      winePackages = [ pkgs.wineWow64Packages.full ];
      extraPackages = [
        pkgs.winetricks
        pkgs.gamescope
        pkgs.gamemode
        pkgs.mangohud
        pkgs.umu-launcher
      ];
    };
  };
}
