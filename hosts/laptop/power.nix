{ ... }:
{
  services.tuned = {
    enable = true;
    ppdSupport = true;
    ppdSettings.main.default = "balanced";
    settings.dynamic_tuning = true;
  };

  services.upower.enable = true;
  services.power-profiles-daemon.enable = false;
  services.tlp.enable = false;

  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "ignore";
  };
}
