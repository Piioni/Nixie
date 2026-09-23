# Default applications for the graphical session.
#
# $XDG_CONFIG_HOME/mimeapps.list decides which application opens a URL, a
# document or a directory when a program asks through xdg-open/gio, and which
# entry a file manager shows as the default for a type. The desktop file IDs
# below were verified against the packages this configuration installs:
# helium.desktop, com.mitchellh.ghostty.desktop, kitty.desktop,
# dev.zed.Zed.desktop, swayimg.desktop, org.gnome.Nautilus.desktop and
# mpv.desktop.
{ ... }:
{
  # xdg-terminal-exec is the proposed cross-desktop entry point for "open a
  # terminal here". The candidates are tried in order, so Kitty is the fallback.
  xdg.terminal-exec = {
    enable = true;

    settings.default = [
      "com.mitchellh.ghostty.desktop"
      "kitty.desktop"
    ];
  };

  xdg.mimeApps = {
    enable = true;

    defaultApplications = {
      "text/html" = [ "helium.desktop" ];
      "application/xhtml+xml" = [ "helium.desktop" ];
      # Helium's built-in viewer is the interim choice here; a dedicated PDF
      # viewer is a separate decision.
      "application/pdf" = [ "helium.desktop" ];

      "x-scheme-handler/http" = [ "helium.desktop" ];
      "x-scheme-handler/https" = [ "helium.desktop" ];
      "x-scheme-handler/ftp" = [ "helium.desktop" ];
      "x-scheme-handler/about" = [ "helium.desktop" ];

      "text/plain" = [ "dev.zed.Zed.desktop" ];
      "text/markdown" = [ "dev.zed.Zed.desktop" ];
      "application/json" = [ "dev.zed.Zed.desktop" ];
      "application/xml" = [ "dev.zed.Zed.desktop" ];

      # The glob entry covers subtypes beyond the explicit ones.
      "image/*" = [ "swayimg.desktop" ];
      "image/png" = [ "swayimg.desktop" ];
      "image/jpeg" = [ "swayimg.desktop" ];
      "image/webp" = [ "swayimg.desktop" ];
      "image/gif" = [ "swayimg.desktop" ];

      "audio/*" = [ "mpv.desktop" ];
      "video/*" = [ "mpv.desktop" ];

      # Nautilus is installed for the GTK portal file chooser, and it is the
      # graphical file manager; Yazi stays the terminal entry point.
      "inode/directory" = [ "org.gnome.Nautilus.desktop" ];

      "x-terminal-emulator" = [ "com.mitchellh.ghostty.desktop" ];
      "x-scheme-handler/terminal" = [ "com.mitchellh.ghostty.desktop" ];
    };
  };
}
