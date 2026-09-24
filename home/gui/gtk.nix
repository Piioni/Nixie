{ config, ... }:
{
  gtk = {
    enable = true;
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = config.programs.noctalia.settings.theme.mode == "dark";
    };

    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = config.programs.noctalia.settings.theme.mode == "dark";
    };
  };
}
