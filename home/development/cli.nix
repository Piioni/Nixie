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
