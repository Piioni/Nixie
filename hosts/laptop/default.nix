{ ... }:
{
  imports = [
    ../../modules
    ../../modules/desktop/dual-sessions.nix
    ./host.nix
    ./home.nix
    ./hardware.nix
    ./power.nix
  ];
}
