{ pkgs, lib, ... }:
{
  programs.kitty = {
    enable = true;

    settings = {
      kitty_mod = "ctrl+shift";
      font_family = "Maple Mono NF";
      font_size = 11;
      bold_font = "auto";
      italic_font = "auto";
      bold_italic_font = "auto";
      remember_window_size = false;
      initial_window_width = 950;
      initial_window_height = 500;
      cursor_shape = "block";
      cursor_blink_interval = 0;
      cursor_stop_blinking_after = 0;
      cursor_trail = 0;
      cursor_trail_decay = "0.1 0.4";
      cursor_trail_start_threshold = 6;
      scrollback_lines = 5000;
      wheel_scroll_min_lines = 1;
      enable_audio_bell = false;
      window_padding_width = 14;
      hide_window_decorations = true;
      background_opacity = 0.93;
      confirm_os_window_close = 0;
      linux_display_server = "wayland";
      shell = "${pkgs.nushell}/bin/nu";
      shell_integration = "no-cursor";
      inactive_text_alpha = 0.92;
      wayland_titlebar_color = "background";
      background_blur = 0;
      tab_bar_style = "hidden";
    };

    keybindings = {
      "kitty_mod+shift+page_up" = "change_font_size all +2.0";
      "kitty_mod+shift+page_down" = "change_font_size all -2.0";
      "kitty_mod+shift+backspace" = "change_font_size all 0";
      "kitty_mod+r" = "load_config_file";
      "ctrl+shift+v" = "paste_from_clipboard";
      "ctrl+shift+c" = "copy_to_clipboard";
    };

    shellIntegration = {
      # Keep the existing Kitty setting above without native shell init snippets.
      mode = null;
      enableBashIntegration = false;
      enableFishIntegration = false;
      enableZshIntegration = false;
    };

    enableGitIntegration = false;

    # Keep the local Catppuccin asset before the declarative settings.
    extraConfig = lib.mkOrder 510 "include Catppuccin-Mocha.conf";
  };

  # The Home Manager Kitty module reloads Kitty by default; retain prior behavior.
  xdg.configFile."kitty/kitty.conf".onChange = lib.mkForce "";

  xdg.configFile = {
    "kitty/Catppuccin-Mocha.conf".source = ./kitty/Catppuccin-Mocha.conf;
    "kitty/utils/scroll_mark.py".source = ./kitty/utils/scroll_mark.py;
    "kitty/utils/search.py".source = ./kitty/utils/search.py;
  };
}
