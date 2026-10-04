{ ... }:
{
  boot.initrd.systemd.enable = true;

  swapDevices = [
    {
      device = "/swapfile";
      size = 20480;
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
