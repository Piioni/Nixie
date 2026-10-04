{ ... }:
{
  services.tuned = {
    enable = true;
    ppdSupport = true;
    ppdSettings.main.default = "balanced";
    settings.dynamic_tuning = true;
  };

  services.upower.enable = true;
  services.thermald.enable = true;
  services.power-profiles-daemon.enable = false;
  services.tlp.enable = false;

  # Closing the lid suspends; after an hour asleep the laptop hibernates to the
  # encrypted swapfile so the battery cannot drain. `remote-work-on` blocks this.
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend-then-hibernate";
    HandleLidSwitchExternalPower = "suspend-then-hibernate";
    HandleLidSwitchDocked = "ignore";
  };

  systemd.sleep.settings.Sleep.HibernateDelaySec = "1h";
}
