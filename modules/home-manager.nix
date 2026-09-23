{
  helium,
  homeManager,
  nixvim,
  username,
  userfullname,
  useremail,
  ...
}:
{
  imports = [
    homeManager.nixosModules.home-manager
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit
        helium
        nixvim
        username
        userfullname
        useremail
        ;
    };
    # The Home Manager user is declared per host, in that host's own home.nix,
    # so the user layer travels through a per-host import path instead of being
    # decided once by the shared system layer.
  };
}
