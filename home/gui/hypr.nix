{ config, lib, pkgs, ... }:
let
  display = config.nixie.workstation.display;
  workstation = config.nixie.workstation;
  luaDir = ./hypr/lua;

  renderLua = name: replacements:
    pkgs.writeText name (
      lib.replaceStrings
        (map (replacement: replacement.from) replacements)
        (map (replacement: replacement.to) replacements)
        (builtins.readFile "${luaDir}/${name}")
    );

  renderMonitors = renderLua "monitors.lua" [
    {
      from = "-- @GENERATED_MONITORS@";
      to = lib.concatMapStrings (output: ''
        hl.monitor({
          output = ${builtins.toJSON output.name},
          mode = ${builtins.toJSON output.mode},
          position = ${builtins.toJSON output.position},
          scale = ${output.scale},
        })

      '') (if display == null then [ ] else display.outputs);
    }
  ];

  renderWorkspacePins = renderLua "workspaces.lua" [
    {
      from = "-- @GENERATED_WORKSPACE_PINS@";
      to = lib.concatMapStrings (pin:
        let
          output = builtins.toJSON pin.output;
          workspaces = "{ ${lib.concatMapStringsSep ", " builtins.toJSON pin.workspaces} }";
          rule = workspace: ''
            hl.workspace_rule({ workspace = ${workspace}, monitor = ${pin.var}, default = true, persistent = true })
          '';
          rules = lib.concatMapStrings rule (map builtins.toJSON pin.workspaces);
          pinBody = ''
            local ${pin.var} = ${output}
            ${rules}
          '';
        in
        if pin.guard == "monitor-exists" then ''
          local ${pin.var} = ${output}
          if hl.get_monitor(${pin.var}) ~= nil then
            ${rules}
          end

        '' else pinBody
      ) (if display == null then [ ] else display.pins);
    }
  ];

  renderInputs = renderLua "inputs.lua" [
    {
      from = "        -- @GENERATED_TOUCHPAD_CONFIG@";
      to = lib.optionalString (workstation.touchpad == true) ''
                -- Tapping is on, but drag lock is off to avoid sticky drags.
                touchpad = {
                    tap_to_click = true,
                    disable_while_typing = true,
                    natural_scroll = true,
                    clickfinger_behavior = true,
                },
      '';
    }
  ];

  renderKeybinds = renderLua "keybinds.lua" [
    {
      from = "-- @GENERATED_BRIGHTNESS_BINDS@";
      to = lib.optionalString (workstation.brightnessKeys == true) ''
        hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"))
        hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"))
      '';
    }
  ];

  luaSources = {
    "animations.lua" = ./hypr/lua/animations.lua;
    "decorations.lua" = ./hypr/lua/decorations.lua;
    "gestures.lua" = ./hypr/lua/gestures.lua;
    "inputs.lua" = renderInputs;
    "keybinds.lua" = renderKeybinds;
    "monitors.lua" = renderMonitors;
    "programs.lua" = ./hypr/lua/programs.lua;
    "settings.lua" = ./hypr/lua/settings.lua;
    "windowrules.lua" = ./hypr/lua/windowrules.lua;
    "workspaces.lua" = renderWorkspacePins;
    "autostart.lua" = ./hypr/lua/autostart.lua;
  };

  luaConfigFiles = lib.mapAttrs' (name: source: {
    name = "hypr/lua/${name}";
    value.source = source;
  }) luaSources;

  workspaceLuaCompatibility = display == null || builtins.all (pin:
    pin.guard == "monitor-exists" || pin.guard == "unconditional"
  ) display.pins;
in
{
  assertions = [
    {
      assertion = workspaceLuaCompatibility;
      message = "nixie.workstation.display pins must use supported monitor guards";
    }
  ];

  home.packages = [
    pkgs.hyprland
    pkgs.hyprpicker
    pkgs.wf-recorder
  ];

  xdg.configFile = luaConfigFiles // {
    "hypr/hyprland.lua".source =
      config.lib.file.mkOutOfStoreSymlink "${config.nixie.home.repositoryRoot}/home/gui/hypr/hyprland.lua";

    "hypr/scripts/colorpicker.sh".source =
      config.lib.file.mkOutOfStoreSymlink "${config.nixie.home.repositoryRoot}/home/gui/hypr/scripts/colorpicker.sh";
    "hypr/scripts/helium-clean-singletons.sh".source =
      config.lib.file.mkOutOfStoreSymlink "${config.nixie.home.repositoryRoot}/home/gui/hypr/scripts/helium-clean-singletons.sh";
    "hypr/scripts/logout.sh".source =
      config.lib.file.mkOutOfStoreSymlink "${config.nixie.home.repositoryRoot}/home/gui/hypr/scripts/logout.sh";
    "hypr/scripts/record.sh".source =
      config.lib.file.mkOutOfStoreSymlink "${config.nixie.home.repositoryRoot}/home/gui/hypr/scripts/record.sh";
  };
}
