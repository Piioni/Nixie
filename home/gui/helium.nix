{ helium, pkgs, ... }:
{
  home.packages = [
    helium.packages.${pkgs.system}.default
  ];
}
