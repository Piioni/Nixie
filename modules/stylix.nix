{ pkgs, stylix, ... }:
{
  imports = [ stylix.nixosModules.default ];

  stylix = {
    enable = true;
    autoEnable = false;

    base16Scheme = {
      system = "base16";
      name = "Catppuccin Mocha";
      author = "https://github.com/catppuccin/catppuccin";
      variant = "dark";
      palette = {
        base00 = "#1e1e2e";
        base01 = "#181825";
        base02 = "#313244";
        base03 = "#45475a";
        base04 = "#585b70";
        base05 = "#cdd6f4";
        base06 = "#f5e0dc";
        base07 = "#b4befe";
        base08 = "#f38ba8";
        base09 = "#fab387";
        base0A = "#f9e2af";
        base0B = "#a6e3a1";
        base0C = "#94e2d5";
        base0D = "#89b4fa";
        base0E = "#cba6f7";
        base0F = "#f2cdcd";
      };
    };
    polarity = "dark";
    image = ../home/gui/noctalia-assets/wallpapers/ryo-night-looking-cam.jpg;

    fonts = {
      monospace = {
        package = pkgs.maple-mono.NF;
        name = "Maple Mono NF";
      };
      sansSerif = {
        package = pkgs.noto-fonts-lgc-plus;
        name = "Noto Sans";
      };
      serif = {
        package = pkgs.noto-fonts-lgc-plus;
        name = "Noto Serif";
      };
      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };
      sizes.applications = 11;
    };

    targets = {
      gtk.enable = true;
      qt = {
        enable = true;
        platform = "qtct";
      };
    };
  };
}
