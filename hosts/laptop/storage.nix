{ ... }:
{
  boot.initrd.systemd.enable = true;

  # zram (priority 100) absorbs everyday swapping; this lower-priority swapfile
  # holds the hibernation image. With systemd in the initrd on UEFI, resume finds
  # the image through the HibernateLocation EFI variable, so no resume_offset is
  # needed. Sized near RAM so hibernation does not fail under heavy workloads.
  swapDevices = [
    {
      device = "/swapfile";
      size = 32768;
    }
  ];

  disko.devices = {
    disk.main = {
      type = "disk";
      # Installation MUST override this nonexistent placeholder:
      # disko-install --flake .#laptop --disk main <device>
      device = "/dev/REPLACE_WITH_TARGET_DISK";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "1G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };
          root = {
            size = "100%";
            content = {
              type = "luks";
              name = "crypted";
              initrdUnlock = true;
              settings.allowDiscards = true;
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };
    };
  };
}
