{ config, lib, ... }:
let
  cfg = config.modules.development;
in
{
  imports = [
    ./android.nix
    ./containers.nix
  ];

  options.modules.development.enable = lib.mkEnableOption "shared development system support";

  config = lib.mkIf cfg.enable {
    # Prebuilt SDKs (FVM's Flutter/Dart, Gradle's aapt2, uv's Python) expect a
    # standard dynamic loader; nix-ld provides it without an FHS system.
    programs.nix-ld.enable = true;

    # File watchers in Flutter, Node and editors exhaust the default limits.
    boot.kernel.sysctl = {
      "fs.inotify.max_user_watches" = 524288;
      "fs.inotify.max_user_instances" = 1024;
    };
  };
}
