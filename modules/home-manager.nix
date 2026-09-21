{ homeManager, ... }:
{
  imports = [
    homeManager.nixosModules.home-manager
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.piioni = import ../home/piioni;
  };
}
