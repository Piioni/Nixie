{ ... }:
{
  home-manager.users.piioni = {
    imports = [
      ../../home/piioni
      ../../home/piioni/base.nix
      ../../home/piioni/gui.nix
      ./facts.nix
    ];
  };
}
