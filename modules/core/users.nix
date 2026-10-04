{
  username,
  sshAuthorizedKeys,
  pkgs,
  ...
}:
{
  programs.nushell.enable = true;
  environment.shells = [ pkgs.nushell ];

  users.users.${username} = {
    isNormalUser = true;
    shell = pkgs.nushell;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    openssh.authorizedKeys.keys = sshAuthorizedKeys;
  };
}
