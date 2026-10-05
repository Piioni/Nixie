{ config, username, ... }:
{
  nixpkgs.config.allowUnfree = true;

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      # Lets the admin user pass flake `nixConfig` and `--option` values; wheel is already root-capable.
      trusted-users = [
        "root"
        username
      ];
      builders-use-substitutes = true;
    };
    # Flakes pin nixpkgs; legacy channels would only drift from it.
    channel.enable = false;
    optimise.automatic = true;
  };

  # nh wraps nixos-rebuild with readable diffs and owns store garbage collection.
  programs.nh = {
    enable = true;
    flake = config.home-manager.users.${username}.nixie.home.repositoryRoot;
    clean = {
      enable = true;
      dates = "weekly";
      extraArgs = "--keep-since 7d --keep 5";
    };
  };
}
