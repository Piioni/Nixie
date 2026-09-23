{
  pkgs,
  config,
  ...
}:
{
  home.packages = [ pkgs.swaynotificationcenter ];

  xdg.configFile = {
    "swaync/config.json".text = builtins.toJSON {
      "$schema" = "/etc/xdg/swaync/configSchema.json";
      positionX = "right";
      positionY = "top";
      layer = "overlay";
      "control-center-layer" = "top";
      "layer-shell" = true;
      cssPriority = "user";
      "control-center-margin-top" = 13;
      "control-center-margin-bottom" = 0;
      "control-center-margin-right" = 14;
      "control-center-margin-left" = 0;
      "notification-2fa-action" = true;
      "notification-inline-replies" = true;
      "notification-icon-size" = 48;
      "notification-body-image-height" = 100;
      "notification-body-image-width" = 100;
      "notification-window-width" = 400;
      timeout = 6;
      "timeout-low" = 3;
      "timeout-critical" = 0;
      "fit-to-screen" = false;
      "control-center-width" = 400;
      "control-center-height" = 1000;
      "keyboard-shortcuts" = true;
      "image-visibility" = "when-available";
      "transition-time" = 200;
      "hide-on-clear" = false;
      "hide-on-action" = true;
      "script-fail-notify" = true;
      widgets = [
        "dnd"
        "buttons-grid"
        "mpris"
        "volume"
        "title"
        "notifications"
      ];
      "widget-config" = {
        title = {
          text = "Notifications";
          "clear-all-button" = true;
          "button-text" = "";
        };
        dnd = {
          text = "Do Not Disturb";
        };
        label = {
          "max-lines" = 1;
          text = "Notification";
        };
        mpris = {
          "image-size" = 50;
          "image-radius" = 0;
        };
        volume = {
          label = "";
        };
        "buttons-grid" = {
          actions = [
            {
              label = "󰤨";
              command = "iwgtk";
            }
            {
              label = "";
              command = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
              type = "toggle";
            }
            {
              label = "";
              command = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
              type = "toggle";
            }
            {
              label = "";
              command = "${config.xdg.configHome}/hypr/scripts/logout.sh";
            }
          ];
        };
      };
    };

    "swaync/style.css".source =
      config.lib.file.mkOutOfStoreSymlink "${config.nixie.home.repositoryRoot}/home/gui/swaync/style.css";
    "swaync/icons/airplane-mode-off.png".source =
      config.lib.file.mkOutOfStoreSymlink "${config.nixie.home.repositoryRoot}/home/gui/swaync/icons/airplane-mode-off.png";
    "swaync/icons/airplane-mode-on.png".source =
      config.lib.file.mkOutOfStoreSymlink "${config.nixie.home.repositoryRoot}/home/gui/swaync/icons/airplane-mode-on.png";
    "swaync/icons/bolt.png".source =
      config.lib.file.mkOutOfStoreSymlink "${config.nixie.home.repositoryRoot}/home/gui/swaync/icons/bolt.png";
    "swaync/icons/brightness-100.png".source =
      config.lib.file.mkOutOfStoreSymlink "${config.nixie.home.repositoryRoot}/home/gui/swaync/icons/brightness-100.png";
    "swaync/icons/brightness-20.png".source =
      config.lib.file.mkOutOfStoreSymlink "${config.nixie.home.repositoryRoot}/home/gui/swaync/icons/brightness-20.png";
    "swaync/icons/brightness-40.png".source =
      config.lib.file.mkOutOfStoreSymlink "${config.nixie.home.repositoryRoot}/home/gui/swaync/icons/brightness-40.png";
    "swaync/icons/brightness-60.png".source =
      config.lib.file.mkOutOfStoreSymlink "${config.nixie.home.repositoryRoot}/home/gui/swaync/icons/brightness-60.png";
    "swaync/icons/brightness-80.png".source =
      config.lib.file.mkOutOfStoreSymlink "${config.nixie.home.repositoryRoot}/home/gui/swaync/icons/brightness-80.png";
    "swaync/icons/gamemode.png".source =
      config.lib.file.mkOutOfStoreSymlink "${config.nixie.home.repositoryRoot}/home/gui/swaync/icons/gamemode.png";
    "swaync/icons/microphone-mute.png".source =
      config.lib.file.mkOutOfStoreSymlink "${config.nixie.home.repositoryRoot}/home/gui/swaync/icons/microphone-mute.png";
    "swaync/icons/microphone.png".source =
      config.lib.file.mkOutOfStoreSymlink "${config.nixie.home.repositoryRoot}/home/gui/swaync/icons/microphone.png";
    "swaync/icons/music.png".source =
      config.lib.file.mkOutOfStoreSymlink "${config.nixie.home.repositoryRoot}/home/gui/swaync/icons/music.png";
    "swaync/icons/palette.png".source =
      config.lib.file.mkOutOfStoreSymlink "${config.nixie.home.repositoryRoot}/home/gui/swaync/icons/palette.png";
    "swaync/icons/picture.png".source =
      config.lib.file.mkOutOfStoreSymlink "${config.nixie.home.repositoryRoot}/home/gui/swaync/icons/picture.png";
    "swaync/icons/play.png".source =
      config.lib.file.mkOutOfStoreSymlink "${config.nixie.home.repositoryRoot}/home/gui/swaync/icons/play.png";
    "swaync/icons/timer.png".source =
      config.lib.file.mkOutOfStoreSymlink "${config.nixie.home.repositoryRoot}/home/gui/swaync/icons/timer.png";
    "swaync/icons/volume-high.png".source =
      config.lib.file.mkOutOfStoreSymlink "${config.nixie.home.repositoryRoot}/home/gui/swaync/icons/volume-high.png";
    "swaync/icons/volume-low.png".source =
      config.lib.file.mkOutOfStoreSymlink "${config.nixie.home.repositoryRoot}/home/gui/swaync/icons/volume-low.png";
    "swaync/icons/volume-mid.png".source =
      config.lib.file.mkOutOfStoreSymlink "${config.nixie.home.repositoryRoot}/home/gui/swaync/icons/volume-mid.png";
    "swaync/icons/volume-mute.png".source =
      config.lib.file.mkOutOfStoreSymlink "${config.nixie.home.repositoryRoot}/home/gui/swaync/icons/volume-mute.png";
    "swaync/icons/wand.png".source =
      config.lib.file.mkOutOfStoreSymlink "${config.nixie.home.repositoryRoot}/home/gui/swaync/icons/wand.png";
  };
}
