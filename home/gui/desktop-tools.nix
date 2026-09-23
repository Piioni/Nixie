{ pkgs, ... }:
{
  home.packages = with pkgs; [
    brightnessctl
    wl-clipboard
    cliphist
    slurp
    grim
  ];

  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
  };
}
