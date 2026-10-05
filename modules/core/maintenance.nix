{ ... }:
{
  services.fwupd.enable = true;
  services.fstrim.enable = true;

  services.journald.extraConfig = ''
    SystemMaxUse=500M
  '';

  # Kill the heaviest user cgroup under memory pressure instead of freezing the desktop.
  systemd.oomd.enableUserSlices = true;
}
