# System-level XDG integration for the graphical sessions.
#
# The portal backends are declared by the nixpkgs compositor modules, not here:
# `programs.hyprland` enables xdg-desktop-portal-hyprland, `programs.niri` adds
# xdg-desktop-portal-gnome, and both import nixos/modules/programs/wayland/
# wayland-session.nix, which adds xdg-desktop-portal-gtk. Hyprland's own
# hyprland-portals.conf is `default=hyprland;gtk`, so FileChooser and OpenURI
# resolve to the GTK portal. Nothing here overrides xdg.portal.config or
# xdg.portal.extraPortals.
{ lib, ... }:
{
  xdg.portal = {
    enable = lib.mkDefault true;

    # Sets NIXOS_XDG_OPEN_USE_PORTAL=1, which routes xdg-open through the portal
    # stack instead of resolving the target itself. Programs running with an
    # unusual environment then reach the session's default applications, which
    # come from home/gui/xdg-apps.nix.
    xdgOpenUsePortal = true;
  };

  # systemd-xdg-autostart-generator starts every autostart application when
  # graphical-session.target is reached, while the portal user services come up
  # around the same time. This template drop-in orders every app-*@autostart
  # service, current and future, after the portal stack, so portal-dependent
  # features such as file choosers and OpenURI work on first launch instead of
  # needing a manual restart of the application.
  systemd.user.units."app-@autostart.service" = {
    overrideStrategy = "asDropin";
    text = ''
      [Unit]
      After=xdg-desktop-portal.service xdg-desktop-portal-gtk.service
      Wants=xdg-desktop-portal.service xdg-desktop-portal-gtk.service
    '';
  };
}
