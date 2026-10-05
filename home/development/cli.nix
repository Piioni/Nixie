{ pkgs, ... }:
{
  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";
      prompt = "enabled";
      aliases.cr = "repo create --source=. --remote=origin --push --private";
    };
  };

  # Per-project environments: a repo's `.envrc` with `use flake` loads its dev shell on cd.
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableNushellIntegration = true;
    config.global.hide_env_diff = true;
  };

  programs.jq.enable = true;
  programs.ripgrep.enable = true;
  programs.fd.enable = true;

  home.packages = with pkgs; [
    just
    kubectl
    lazydocker
    bruno
  ];
}
