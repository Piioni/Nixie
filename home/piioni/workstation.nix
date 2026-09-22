{ config, lib, ... }:
let
  inherit (lib) mkOption types;

  output = types.submodule {
    options = {
      name = mkOption {
        type = types.str;
        description = "Hyprland output name, e.g. eDP-1.";
      };
      mode = mkOption {
        type = types.str;
        description = "Hyprland mode string, e.g. 1920x1080@60.";
      };
      position = mkOption {
        type = types.str;
        description = "Hyprland position string, e.g. 0x0.";
      };
      scale = mkOption {
        type = types.str;
        description = "Raw Lua literal emitted for `scale`; Hyprland reads it as a float.";
      };
    };
  };

  pin = types.submodule {
    options = {
      var = mkOption {
        type = types.str;
        description = "Lua local binding name used inside the pin block.";
      };
      output = mkOption {
        type = types.str;
        description = "Output name this pin group targets.";
      };
      guard = mkOption {
        type = types.enum [
          "monitor-exists"
          "unconditional"
        ];
        description = "Failure semantics of this pin group; the two are rendered by distinct branches.";
      };
      workspaces = mkOption {
        type = types.listOf types.str;
        description = "Workspace names to pin.";
      };
    };
  };

  display = types.submodule {
    options = {
      outputs = mkOption {
        type = types.listOf output;
        description = "Captured display outputs, in declaration order.";
      };
      pins = mkOption {
        type = types.listOf pin;
        description = "Captured workspace pin groups, in declaration order.";
      };
    };
  };
in
{
  options.nixie.workstation = {
    display = mkOption {
      type = types.nullOr display;
      description = "Captured display topology. `null` means NOT CAPTURED (no directives, no pins, compositor auto-detects).";
    };
    touchpad = mkOption {
      type = types.bool;
      description = "This machine has a touchpad.";
    };
    brightnessKeys = mkOption {
      type = types.bool;
      description = "This machine has backlight brightness keys.";
    };
    batteryUi = mkOption {
      type = types.bool;
      description = "This machine has a battery whose level is shown in the UI.";
    };
  };

  config = {
    warnings = lib.optional (config.nixie.workstation.display == null) ''
      nixie: this host's display topology is not captured
      (nixie.workstation.display = null). No monitor directives and no workspace pins
      will be emitted; the compositor will auto-detect. Capture with `hyprctl monitors`
      and fill the host's facts.nix.
    '';
  };
}
