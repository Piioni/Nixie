{ ... }:
{
  imports = [
    ../../modules
    ../../modules/desktop/dual-sessions.nix
    ../../modules/desktop/xdg.nix
    ./host.nix
    ./home.nix
    ./hardware.nix
    ./gaming.nix
  ];
}
