{ pkgs, ... }:
{
  fonts.packages = [
    pkgs.maple-mono.NF
    pkgs.noto-fonts-lgc-plus
    pkgs.noto-fonts-color-emoji
  ];

  fonts.fontconfig.defaultFonts = {
    monospace = [
      "Maple Mono NF"
      "Noto Sans Mono"
    ];
    sansSerif = [ "Noto Sans" ];
    serif = [ "Noto Serif" ];
    emoji = [ "Noto Color Emoji" ];
  };
}
