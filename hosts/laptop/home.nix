{ ... }:
{
  home-manager.users.piioni.imports = [
    ../../home
    ../../home/hosts/laptop.nix
  ];
}
