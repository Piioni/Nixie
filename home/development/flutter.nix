{ config, pkgs, ... }:
let
  home = config.home.homeDirectory;
in
{
  # FVM downloads each project's pinned SDK into ~/fvm; nix-ld runs its Dart binaries.
  home.packages = [ pkgs.fvm ];

  home.sessionPath = [
    "${home}/fvm/default/bin"
    "${home}/.pub-cache/bin"
  ];
}
