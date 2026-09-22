# WU3a intermediate state (deliberate, recorded): this file mirrors the laptop's
# facts so that the byte-equality witness covers both hosts. WU4 owns the final
# desktop values (`display = null`, `touchpad`/`brightnessKeys`/`batteryUi` =
# false) and removes this comment.
{ ... }:
{
  nixie.workstation = {
    display = {
      outputs = [
        {
          name = "eDP-1";
          mode = "1920x1080@60";
          position = "0x0";
          scale = "1";
        }
        {
          name = "HDMI-A-1";
          mode = "1920x1080@120";
          position = "1920x0";
          scale = "1";
        }
      ];
      pins = [
        {
          var = "hdmi";
          output = "HDMI-A-1";
          guard = "monitor-exists";
          workspaces = [
            "1"
            "2"
            "3"
            "4"
          ];
        }
        {
          var = "edp";
          output = "eDP-1";
          guard = "unconditional";
          workspaces = [
            "5"
            "6"
          ];
        }
      ];
    };
    touchpad = true;
    brightnessKeys = true;
    batteryUi = true;
  };
}
