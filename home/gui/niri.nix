{
  config,
  lib,
  osConfig,
  ...
}:
{
  wayland.windowManager.niri = {
    enable = true;
    package = osConfig.programs.niri.package;
    checkConfig = true;
    systemd.enable = false;
    portalPackage = null;
    xwaylandSatellitePackage = null;

    settings = {
      _children = [
        # Input devices and gestures.
        {
          input = {
            _children = [
              { mod-key = "Super"; }
              { mod-key-nested = "Super"; }
              {
                keyboard = {
                  _children = [
                    { xkb.layout = "es"; }
                    { numlock = { }; }
                  ];
                };
              }
            ]
            ++ lib.optional (config.nixie.workstation.touchpad == true) {
              touchpad = {
                _children = [
                  { tap = { }; }
                  { natural-scroll = { }; }
                ];
              };
            };
          };
        }
        {
          gestures.hot-corners.off = { };
        }

        # Named workspaces, kept in their declared order.
        { workspace._args = [ "coding" ]; }
        { workspace._args = [ "browser" ]; }
        { workspace._args = [ "music" ]; }
        { workspace._args = [ "social" ]; }

        {
          layout = {
            _children = [
              { gaps = 16; }
              { center-focused-column = "never"; }
              {
                preset-column-widths._children = [
                  { proportion = 0.33333; }
                  { proportion = 0.5; }
                  { proportion = 0.66667; }
                ];
              }
              { default-column-width.proportion = 0.5; }
              {
                focus-ring = {
                  _children = [
                    { width = 2; }
                    { active-color = "#7aa2f7"; }
                    { inactive-color = "#565f89"; }
                  ];
                };
              }
              {
                border = {
                  _children = [
                    { off = { }; }
                    { width = 2; }
                    { active-color = "#e0af68"; }
                    { inactive-color = "#565f89"; }
                    { urgent-color = "#f7768e"; }
                  ];
                };
              }
              {
                shadow = {
                  _children = [
                    { softness = 30; }
                    { spread = 5; }
                    {
                      offset._props = {
                        x = 0;
                        y = 5;
                      };
                    }
                    { color = "#0007"; }
                  ];
                };
              }
            ];
          };
        }

        # Niri starts Noctalia here; Hyprland starts it from its own autostart.
        # Startup processes.
        {
          spawn-at-startup._args = [
            "env"
            "QT_IM_MODULE=wayland"
            "QT_QPA_PLATFORM=wayland"
            "noctalia"
          ];
        }
        {
          spawn-at-startup._args = [
            "wl-paste"
            "--type"
            "text"
            "--watch"
            "cliphist"
            "store"
          ];
        }
        {
          spawn-at-startup._args = [
            "wl-paste"
            "--type"
            "image"
            "--watch"
            "cliphist"
            "store"
          ];
        }
        {
          spawn-at-startup._args = [
            "gnome-keyring-daemon"
            "--start"
            "--components=secrets"
          ];
        }

        { hotkey-overlay.skip-at-startup = { }; }
        { prefer-no-csd = { }; }
        { debug.honor-xdg-activation-with-invalid-serial = { }; }
        {
          environment = {
            _children = [
              { QT_QPA_PLATFORM = "wayland"; }
              { XDG_CURRENT_DESKTOP = "niri"; }
              { XDG_SESSION_TYPE = "wayland"; }
            ];
          };
        }
        {
          screenshot-path = "${config.xdg.userDirs.pictures}/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";
        }

        # Window rules; _children retains repeated matches and rule ordering.
        {
          window-rule._children = [
            { match._props.app-id = "(code|visual-studio-code|com\\.visualstudio\\.code)$"; }
            { match._props.app-id = "(zed|Zed|dev\\.zed\\.Zed)$"; }
            { open-on-workspace = "coding"; }
            { open-maximized = true; }
          ];
        }
        {
          window-rule._children = [
            { match._props.app-id = "(helium|Helium|firefox)$"; }
            { open-on-workspace = "browser"; }
            { open-maximized = true; }
          ];
        }
        {
          window-rule._children = [
            { match._props.app-id = "(spotify|com\\.spotify\\.Client)$"; }
            { open-on-workspace = "music"; }
            { open-maximized = true; }
          ];
        }
        {
          window-rule._children = [
            { match._props.app-id = "(vesktop|dev\\.vesktop\\.Vesktop|slack|com\\.slack\\.Slack)$"; }
            { open-on-workspace = "social"; }
            { open-maximized = true; }
          ];
        }
        {
          window-rule._children = [
            { match._props.app-id = "(bitwarden|com\\.bitwarden\\.desktop)$"; }
            { open-floating = true; }
            { default-column-width.fixed = 900; }
            { default-window-height.fixed = 650; }
          ];
        }
        {
          window-rule._children = [
            { match._props.app-id = "ghostty"; }
            { opacity = 0.9; }
          ];
        }
        {
          window-rule._children = [
            {
              match._props = {
                app-id = "firefox$";
                title = "^Picture-in-Picture$";
              };
            }
            { open-floating = true; }
          ];
        }
        {
          window-rule._children = [
            { geometry-corner-radius = 20; }
            { clip-to-geometry = true; }
          ];
        }

        {
          binds = {
            "Mod+Shift+T".toggle-window-rule-opacity = { };
            "Alt+Shift+Slash".show-hotkey-overlay = { };

            # Applications and Noctalia controls.
            "Mod+Return" = {
              _props.hotkey-overlay-title = "Open a Terminal: Ghostty";
              spawn = [ "ghostty" ];
            };
            "Mod+B" = {
              _props.hotkey-overlay-title = "Open the browser";
              spawn = [ "helium" ];
            };
            "Mod+E" = {
              _props.hotkey-overlay-title = "Open the file manager";
              spawn = [ "nautilus" ];
            };
            "Mod+R" = {
              _props.hotkey-overlay-title = "Open Noctalia launcher";
              spawn = [
                "noctalia"
                "msg"
                "panel-toggle"
                "launcher"
              ];
            };
            "Mod+N" = {
              _props.hotkey-overlay-title = "Open Noctalia notifications";
              spawn = [
                "noctalia"
                "msg"
                "panel-toggle"
                "notifications"
              ];
            };
            "Mod+Shift+C" = {
              _props.hotkey-overlay-title = "Open Noctalia control center";
              spawn = [
                "noctalia"
                "msg"
                "panel-toggle"
                "control-center"
              ];
            };
            "Mod+P" = {
              _props.hotkey-overlay-title = "Screenshot region to clipboard";
              spawn = [
                "sh"
                "-c"
                ''grim -g "$(slurp)" - | wl-copy''
              ];
            };
            "Mod+Ctrl+P" = {
              _props.hotkey-overlay-title = "Screenshot region to Swappy";
              spawn = [
                "sh"
                "-c"
                ''grim -g "$(slurp)" - | swappy -f -''
              ];
            };

            # Audio and brightness.
            "XF86AudioRaiseVolume" = {
              _props.allow-when-locked = true;
              spawn = [
                "wpctl"
                "set-volume"
                "@DEFAULT_AUDIO_SINK@"
                "0.1+"
              ];
            };
            "XF86AudioLowerVolume" = {
              _props.allow-when-locked = true;
              spawn = [
                "wpctl"
                "set-volume"
                "@DEFAULT_AUDIO_SINK@"
                "0.1-"
              ];
            };
            "XF86AudioMute" = {
              _props.allow-when-locked = true;
              spawn = [
                "wpctl"
                "set-mute"
                "@DEFAULT_AUDIO_SINK@"
                "toggle"
              ];
            };
            "XF86AudioMicMute" = {
              _props.allow-when-locked = true;
              spawn = [
                "wpctl"
                "set-mute"
                "@DEFAULT_AUDIO_SOURCE@"
                "toggle"
              ];
            };

            # Window management.
            "Mod+O".toggle-overview = { };
            "Mod+Q".close-window = { };
            "Mod+Left".focus-column-left = { };
            "Mod+Down".focus-window-down = { };
            "Mod+Up".focus-window-up = { };
            "Mod+Right".focus-column-right = { };
            "Mod+H".focus-column-left = { };
            "Mod+J".focus-window-down = { };
            "Mod+K".focus-window-up = { };
            "Mod+L".focus-column-right = { };
            "Mod+Ctrl+Left".move-column-left = { };
            "Mod+Ctrl+Down".move-window-down = { };
            "Mod+Ctrl+Up".move-window-up = { };
            "Mod+Ctrl+Right".move-column-right = { };
            "Mod+Ctrl+H".move-column-left = { };
            "Mod+Ctrl+J".move-window-down = { };
            "Mod+Ctrl+K".move-window-up = { };
            "Mod+Ctrl+L".move-column-right = { };
            "Mod+Home".focus-column-first = { };
            "Mod+End".focus-column-last = { };
            "Mod+Ctrl+Home".move-column-to-first = { };
            "Mod+Ctrl+End".move-column-to-last = { };
            "Mod+Shift+Left".focus-monitor-left = { };
            "Mod+Shift+Down".focus-monitor-down = { };
            "Mod+Shift+Up".focus-monitor-up = { };
            "Mod+Shift+Right".focus-monitor-right = { };
            "Mod+Shift+H".focus-monitor-left = { };
            "Mod+Shift+J".focus-monitor-down = { };
            "Mod+Shift+K".focus-monitor-up = { };
            "Mod+Shift+L".focus-monitor-right = { };
            "Mod+Shift+Ctrl+Left".move-column-to-monitor-left = { };
            "Mod+Shift+Ctrl+Down".move-column-to-monitor-down = { };
            "Mod+Shift+Ctrl+Up".move-column-to-monitor-up = { };
            "Mod+Shift+Ctrl+Right".move-column-to-monitor-right = { };
            "Mod+Shift+Ctrl+H".move-column-to-monitor-left = { };
            "Mod+Shift+Ctrl+J".move-column-to-monitor-down = { };
            "Mod+Shift+Ctrl+K".move-column-to-monitor-up = { };
            "Mod+Shift+Ctrl+L".move-column-to-monitor-right = { };
            "Mod+Page_Down".focus-workspace-down = { };
            "Mod+Page_Up".focus-workspace-up = { };
            "Mod+U".focus-workspace-down = { };
            "Mod+I".focus-workspace-up = { };
            "Mod+Ctrl+Page_Down".move-column-to-workspace-down = { };
            "Mod+Ctrl+Page_Up".move-column-to-workspace-up = { };
            "Mod+Ctrl+U".move-column-to-workspace-down = { };
            "Mod+Ctrl+I".move-column-to-workspace-up = { };
            "Mod+Shift+Page_Down".move-workspace-down = { };
            "Mod+Shift+Page_Up".move-workspace-up = { };
            "Mod+Shift+U".move-workspace-down = { };
            "Mod+Shift+I".move-workspace-up = { };
            "Mod+WheelScrollDown" = {
              _props.cooldown-ms = 150;
              focus-workspace-down = { };
            };
            "Mod+WheelScrollUp" = {
              _props.cooldown-ms = 150;
              focus-workspace-up = { };
            };
            "Mod+Ctrl+WheelScrollDown" = {
              _props.cooldown-ms = 150;
              move-column-to-workspace-down = { };
            };
            "Mod+Ctrl+WheelScrollUp" = {
              _props.cooldown-ms = 150;
              move-column-to-workspace-up = { };
            };
            "Mod+WheelScrollRight".focus-column-right = { };
            "Mod+WheelScrollLeft".focus-column-left = { };
            "Mod+Ctrl+WheelScrollRight".move-column-right = { };
            "Mod+Ctrl+WheelScrollLeft".move-column-left = { };
            "Mod+Shift+WheelScrollDown".focus-column-right = { };
            "Mod+Shift+WheelScrollUp".focus-column-left = { };
            "Mod+Ctrl+Shift+WheelScrollDown".move-column-right = { };
            "Mod+Ctrl+Shift+WheelScrollUp".move-column-left = { };

            # Workspaces by number.
            "Mod+1".focus-workspace = [ 1 ];
            "Mod+2".focus-workspace = [ 2 ];
            "Mod+3".focus-workspace = [ 3 ];
            "Mod+4".focus-workspace = [ 4 ];
            "Mod+5".focus-workspace = [ 5 ];
            "Mod+6".focus-workspace = [ 6 ];
            "Mod+7".focus-workspace = [ 7 ];
            "Mod+8".focus-workspace = [ 8 ];
            "Mod+9".focus-workspace = [ 9 ];
            "Mod+Shift+1".move-column-to-workspace = [ 1 ];
            "Mod+Shift+2".move-column-to-workspace = [ 2 ];
            "Mod+Shift+3".move-column-to-workspace = [ 3 ];
            "Mod+Shift+4".move-column-to-workspace = [ 4 ];
            "Mod+Shift+5".move-column-to-workspace = [ 5 ];
            "Mod+Shift+6".move-column-to-workspace = [ 6 ];
            "Mod+Shift+7".move-column-to-workspace = [ 7 ];
            "Mod+Shift+8".move-column-to-workspace = [ 8 ];
            "Mod+Shift+9".move-column-to-workspace = [ 9 ];

            "Mod+BracketLeft".consume-or-expel-window-left = { };
            "Mod+BracketRight".consume-or-expel-window-right = { };
            "Mod+Comma".consume-window-into-column = { };
            "Mod+Period".expel-window-from-column = { };
            "Mod+Shift+R".switch-preset-window-height = { };
            "Mod+Ctrl+R".reset-window-height = { };
            "Mod+F".maximize-column = { };
            "Mod+Shift+F".fullscreen-window = { };
            "Mod+Ctrl+F".expand-column-to-available-width = { };
            "Mod+C".center-column = { };
            "Mod+Ctrl+C".center-visible-columns = { };
            "Mod+Minus".set-column-width = [ "-10%" ];
            "Mod+Equal".set-column-width = [ "+10%" ];
            "Mod+Shift+Minus".set-window-height = [ "-10%" ];
            "Mod+Shift+Equal".set-window-height = [ "+10%" ];
            "Mod+V".toggle-window-floating = { };
            "Mod+Shift+V".switch-focus-between-floating-and-tiling = { };
            "Mod+W".toggle-column-tabbed-display = { };
            Print.screenshot = { };
            "Ctrl+Print".screenshot-screen = { };
            "Alt+Print".screenshot-window = { };
            "Mod+Escape" = {
              _props.allow-inhibiting = false;
              toggle-keyboard-shortcuts-inhibit = { };
            };
            "Mod+Shift+E".quit = { };
            "Ctrl+Alt+Delete".quit = { };
          }
          // lib.optionalAttrs (config.nixie.workstation.brightnessKeys == true) {
            "XF86MonBrightnessUp" = {
              _props.allow-when-locked = true;
              spawn = [
                "brightnessctl"
                "--class=backlight"
                "set"
                "+10%"
              ];
            };
            "XF86MonBrightnessDown" = {
              _props.allow-when-locked = true;
              spawn = [
                "brightnessctl"
                "--class=backlight"
                "set"
                "10%-"
              ];
            };
          };
        }
      ];
    };
  };
}
