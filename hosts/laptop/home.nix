{ pkgs, username, ... }:
{
  home-manager.users.${username} = {
    imports = [
      ../../home
    ];

    home.packages = [ pkgs.google-chrome ];

    # Live symlinks point at this checkout on the machine itself.
    nixie.home.repositoryRoot = "/home/${username}/nix-config";
  };
}
