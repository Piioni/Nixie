{ ... }:
{
  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };
    grub = {
      enable = true;
      efiSupport = true;
      device = "nodev";
      # Keep the 1 GiB ESP from filling with old kernels.
      configurationLimit = 10;
    };
  };
}
