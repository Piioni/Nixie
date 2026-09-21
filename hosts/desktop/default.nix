{ lib, ... }:
{
  imports = [
    ../../modules
    ./host.nix
    ../../modules/hardware/nvidia.nix
  ]
  ++ lib.optional (builtins.pathExists ./hardware-configuration.nix) ./hardware-configuration.nix;
}
