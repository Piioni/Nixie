{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.proton-vpn-cli ];
}
