{ ... }:
{
  services.tuned = {
    enable = true;
    ppdSupport = true;
    ppdSettings.main.default = "performance";
    settings.dynamic_tuning = true;
  };

  services.upower.enable = true;
  services.power-profiles-daemon.enable = false;
  services.tlp.enable = false;
}
