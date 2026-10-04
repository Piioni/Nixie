{ pkgs, username, ... }:
{
  home-manager.users.${username} = {
    imports = [
      ../../home
    ];

    home.packages = [ pkgs.google-chrome ];
    # Flutter web targets launch this browser.
    home.sessionVariables.CHROME_EXECUTABLE = "${pkgs.google-chrome}/bin/google-chrome-stable";

    # Live symlinks point at this checkout on the machine itself.
    nixie.home.repositoryRoot = "/home/${username}/nix-config";
  };
}
