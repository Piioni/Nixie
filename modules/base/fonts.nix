{ pkgs, ... }:
{
  fonts.packages = [
    pkgs.maple-mono.NF
    pkgs.noto-fonts-lgc-plus
    pkgs.noto-fonts-color-emoji
  ];
}
