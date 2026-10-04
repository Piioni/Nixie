{ pkgs, ... }:
{
  home.packages = [
    pkgs.codex
    (pkgs.callPackage ../../packages/gentle-ai.nix { })
    (pkgs.callPackage ../../packages/engram.nix { })
    (pkgs.callPackage ../../packages/gga.nix { })
  ];
}
