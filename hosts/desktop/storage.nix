{ ... }:
{
  swapDevices = [
    {
      device = "/swapfile";
      size = 20480;
    }
  ];

  disko.devices = {
    disk.main = {
      type = "disk";
      # Replace with the target disk's /dev/disk/by-id path before installing (see README.md).
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
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
            };
          };
        };
      };
    };
  };
}
