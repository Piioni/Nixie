{ config, ... }:
{
  gtk = {
    enable = true;
    font = {
      name = "Noto Sans";
      size = 11;
    };

    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = config.programs.noctalia.settings.theme.mode == "dark";
    };

    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = config.programs.noctalia.settings.theme.mode == "dark";
    };
  };
}
