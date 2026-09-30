{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    brightnessctl
    wl-clipboard
    cliphist
    slurp
    grim
  ];

  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
  };

  programs.swappy = {
    enable = true;

    settings.Default = {
      save_dir = "${config.xdg.userDirs.pictures}/Screenshots";
      save_filename_format = "hypr-%Y%m%d-%H%M%S.png";
      show_panel = false;
      line_size = 5;
      text_size = 20;
      paint_mode = "brush";
      early_exit = false;
      fill_shape = false;
    };
  };

 
}
