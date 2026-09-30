{ lib, ... }:
{
  imports = [
    ./nvidia.nix
  ]
  ++ lib.optional (builtins.pathExists ./hardware-configuration.nix) ./hardware-configuration.nix;
}
