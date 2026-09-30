{ ... }:
{
  imports = [
    ../../modules
    ../../modules/sessions.nix
    ../../modules/xdg.nix
    ../../modules/gaming.nix
    ../../modules/zram.nix
    ./host.nix
    ./home.nix
    ./hardware.nix
    ./boot.nix
    ./storage.nix
    ./power.nix
    ./peripherals.nix
    ./gaming.nix
  ];

  modules.zram.enable = false;
}
