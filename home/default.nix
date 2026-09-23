{
  username,
  config,
  lib,
  ...
}:
{
  imports = [
    ./agents
    ./core
    ./gui
  ];

  options.nixie.home.repositoryRoot = lib.mkOption {
    type = lib.types.str;
    default = "${config.home.homeDirectory}/nix-config";
    description = "Path to the editable Nixie checkout used for live dotfile symlinks.";
  };

  config = {
    home.username = username;
    home.homeDirectory = "/home/${username}";
    home.stateVersion = "25.11";

    programs.home-manager.enable = true;
  };
}
