# XDG Base Directory and user directory policy for the shared home layer.
{ config, pkgs, ... }:
{
  # Home Manager already writes every xdg.configFile and xdg.dataFile target to
  # ~/.config and ~/.local/share whether or not this switch is on. Enabling it
  # additionally exports XDG_CONFIG_HOME, XDG_DATA_HOME, XDG_CACHE_HOME and
  # XDG_STATE_HOME to the login session and to the systemd user session, so user
  # services and programs that do not go through GLib stop falling back to $HOME.
  xdg.enable = true;

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    setSessionVariables = true;
    extraConfig = {
      # Niri writes its screenshots here, and `createDirectories` above creates
      # the directory during activation. The module renders this key as
      # XDG_SCREENSHOTS_DIR, so it also reads back with `xdg-user-dir SCREENSHOTS`.
      SCREENSHOTS = "${config.xdg.userDirs.pictures}/Screenshots";
    };
  };

  # xdg-open and xdg-mime come from xdg-utils. xdg-user-dirs itself is installed
  # by the xdg.userDirs module above, so it is not listed here.
  home.packages = [ pkgs.xdg-utils ];
}
