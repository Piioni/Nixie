{ ... }:
{
  networking.hostName = "desktop";

  users.users.piioni = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    initialPassword = "piioni";
  };
}
