{ ... }:
{
  imports = [
    ./networking.nix
    ./tailscale.nix
    ./vpn.nix
    ./localsend.nix
  ];
}
