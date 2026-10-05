{ ... }:
{
  # tuned is the single power manager; hosts pick its default profile.
  services.tuned = {
    enable = true;
    ppdSupport = true;
    settings.dynamic_tuning = true;
  };

  services.upower.enable = true;
  services.power-profiles-daemon.enable = false;
  services.tlp.enable = false;
}
