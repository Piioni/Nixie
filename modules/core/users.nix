{ username, sshAuthorizedKeys, ... }:
{
  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    openssh.authorizedKeys.keys = sshAuthorizedKeys;
  };
}
