{ lib, ... }:
{
  imports = [
    ../../modules
    ./host.nix
    ./gpu-nvidia.nix
  ]
  ++ lib.optional (builtins.pathExists ./hardware-configuration.nix) ./hardware-configuration.nix;
}
