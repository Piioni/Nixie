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
  };
}
