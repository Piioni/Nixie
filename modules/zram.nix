{ config, lib, ... }:
{
  options.modules.zram.enable = lib.mkEnableOption "conservative ZRAM swap";

  config = lib.mkIf config.modules.zram.enable {
    zramSwap = {
      enable = true;
      algorithm = "zstd";
      memoryPercent = 25;
      priority = 100;
    };

    boot.kernel.sysctl = {
      "vm.swappiness" = 100;
      "vm.page-cluster" = 0;
    };
  };
}
