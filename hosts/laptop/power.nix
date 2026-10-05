{ ... }:
{
  services.tuned.ppdSettings.main.default = "balanced";
  services.thermald.enable = true;

  # Closing the lid suspends; after an hour asleep the laptop hibernates to the
  # encrypted swapfile so the battery cannot drain. `remote-work-on` blocks this.
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend-then-hibernate";
    HandleLidSwitchExternalPower = "suspend-then-hibernate";
    HandleLidSwitchDocked = "ignore";
  };

  systemd.sleep.settings.Sleep.HibernateDelaySec = "1h";
}
