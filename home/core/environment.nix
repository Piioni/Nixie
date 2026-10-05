{ config, ... }:
{
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    TERMINAL = "ghostty";
    BROWSER = "helium";
  };

  # Login shells read home.sessionVariables; apps started from the Niri session
  # inherit the systemd user environment instead, so mirror the same values there.
  systemd.user.sessionVariables = config.home.sessionVariables;
}
