{
  config,
  lib,
  username,
  ...
}:
{
  options.modules.development.docker.enable =
    lib.mkEnableOption "the Docker engine with Compose and Buildx";

  config = lib.mkIf config.modules.development.docker.enable {
    virtualisation.docker = {
      enable = true;
      # Socket activation starts the daemon on first use instead of at boot.
      enableOnBoot = false;
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
    };

    # Membership in the docker group is effectively root access.
    users.users.${username}.extraGroups = [ "docker" ];
  };
}
