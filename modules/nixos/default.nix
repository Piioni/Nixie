{ ... }:
{
  imports = [
    ./networking.nix
    ./locale.nix
    ./nix.nix
    ./services.nix
    ./packages.nix
    ./system.nix
  ];
}
