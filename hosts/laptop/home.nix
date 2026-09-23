{ username, ... }:
{
  home-manager.users.${username}.imports = [
    ../../home
    ../../home/hosts/laptop.nix
  ];
}
