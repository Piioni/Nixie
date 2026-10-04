{ ... }:
{
  imports = [
    ../../modules
    ./home.nix
    ./hardware.nix
    ./boot.nix
    ./storage.nix
    ./power.nix
    ./graphics.nix
    ./gaming.nix
  ];

  networking.hostName = "laptop";
  system.stateVersion = "25.11";
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  modules.zram.enable = true;
  modules.development = {
    enable = true;
    docker.enable = true;
    android.enable = true;
  };
}
