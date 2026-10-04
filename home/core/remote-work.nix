{ pkgs, ... }:
let
  unit = "remote-work";
  systemctl = "/run/current-system/sw/bin/systemctl";

  remoteWorkOn = pkgs.writeShellApplication {
    name = "remote-work-on";
    text = ''
      if ${systemctl} --user is-active --quiet ${unit}.service; then
        echo "Remote work mode is already active."
        exit 0
      fi

      # A block inhibitor keeps the machine awake, including with the lid closed,
      # until the transient unit stops.
      /run/current-system/sw/bin/systemd-run \
        --user \
        --unit=${unit} \
        --collect \
        --quiet \
        /run/current-system/sw/bin/systemd-inhibit \
        --what="sleep:idle:handle-lid-switch" \
        --mode=block \
        --who="$(id -un)" \
        --why="Remote work session" \
        ${pkgs.coreutils}/bin/sleep infinity

      echo "Remote work mode enabled: idle, lid-close and suspend sleep are blocked."
      echo "Disable it with: remote-work-off"
    '';
  };

  remoteWorkOff = pkgs.writeShellApplication {
    name = "remote-work-off";
    text = ''
      if ! ${systemctl} --user is-active --quiet ${unit}.service; then
        echo "Remote work mode is already inactive."
        exit 0
      fi

      ${systemctl} --user stop ${unit}.service
      echo "Remote work mode disabled: closing the lid suspends again."
    '';
  };
in
{
  home.packages = [
    remoteWorkOn
    remoteWorkOff
  ];
}
