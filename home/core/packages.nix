{ pkgs, ... }:
{
  home.packages = with pkgs; [
    bat
    neovim
  ];
}
