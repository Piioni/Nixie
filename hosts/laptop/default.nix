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

  networking.hostName = "laptop";
  system.stateVersion = "25.11";
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  modules.zram.enable = true;
}
