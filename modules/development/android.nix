{
  config,
  lib,
  pkgs,
  username,
  ...
}:
let
  jdk = pkgs.jdk17;
  sdkRoot = "/home/${username}/Android/Sdk";
in
{
  options.modules.development.android.enable =
    lib.mkEnableOption "Android and Flutter mobile tooling";

  config = lib.mkIf config.modules.development.android.enable {
    modules.development.enable = true;

    # Android Studio owns a mutable SDK under ~/Android/Sdk so Gradle can install
    # the platforms, build tools and NDK each project pins.
    environment.systemPackages = [
      pkgs.android-studio
      pkgs.android-tools
      jdk
    ];

    # Session variables reach every login shell (including Nushell) through PAM.
    environment.sessionVariables = {
      ANDROID_HOME = sdkRoot;
      ANDROID_SDK_ROOT = sdkRoot;
      JAVA_HOME = "${jdk}/lib/openjdk";
    };

    # Emulator acceleration; adb device access comes from systemd uaccess rules.
    users.users.${username}.extraGroups = [ "kvm" ];
  };
}
