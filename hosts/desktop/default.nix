{ ... }:
{
  imports = [
    ../../modules
    ./home.nix
    ./hardware.nix
    ./boot.nix
    ./storage.nix
    ./power.nix
    ./gaming.nix
  ];

  networking.hostName = "desktop";
  system.stateVersion = "25.11";
  hardware.bluetooth.enable = true;

  modules.zram.enable = false;
}
