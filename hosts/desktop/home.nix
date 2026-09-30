{ username, ... }:
{
  home-manager.users.${username} = {
    imports = [
      ../../home
    ];

    nixie.workstation = {
      display = null;
      touchpad = null;
      brightnessKeys = null;
      batteryUi = null;
    };
  };
}
