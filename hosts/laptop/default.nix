{ lib, ... }:
{
  imports = [
    ../../modules
    ./host.nix
    ./home.nix
  ]
  ++ lib.optional (builtins.pathExists ./hardware-configuration.nix) ./hardware-configuration.nix;
}
