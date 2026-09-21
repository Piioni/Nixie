{ pkgs, ... }:
{
  home.packages = with pkgs; [
    bat
    fzf
    neovim
  ];
}
