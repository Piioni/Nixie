{ ... }:
{
  imports = [
    ../../modules
    ../../modules/sessions.nix
    ../../modules/xdg.nix
    ../../modules/gaming.nix
    ./host.nix
    ./home.nix
    ./hardware.nix
    ./boot.nix
    ./storage.nix
    ./power.nix
    ./gaming.nix
  ];
}
