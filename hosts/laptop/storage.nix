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
      # Stable ID of the laptop's internal NVMe; disko wipes exactly this disk.
      device = "/dev/disk/by-id/nvme-SKHynix_HFM256GD3HX015N_FNB1N546212501H4L";
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
