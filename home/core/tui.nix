{ ... }:
{
  programs = {
    fzf = {
      enable = true;
      enableBashIntegration = false;
      enableFishIntegration = false;
      enableNushellIntegration = false;
      enableZshIntegration = false;
    };

    bat.enable = true;

    eza = {
      enable = true;
      git = true;
      icons = "auto";
      enableBashIntegration = false;
      enableFishIntegration = false;
      enableNushellIntegration = false;
      enableZshIntegration = false;
    };

    zoxide = {
      enable = true;
      enableBashIntegration = false;
      enableFishIntegration = false;
      enableNushellIntegration = true;
      enableZshIntegration = false;
    };

    lazygit.enable = true;
  };
}
