{ username, ... }:
{
  home-manager.users.${username} = {
    imports = [
      ../../home
    ];

    # Live symlinks point at this checkout on the machine itself.
    nixie.home.repositoryRoot = "/home/${username}/nix-config";
  };
}
