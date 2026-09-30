{ pkgs, ... }:
{
  home.packages = [ pkgs.tuxedo-rs ];

  xdg.configFile."tuxedo/config.toml".text = ''
    # tuxedo config
    theme = Muted Slate
    density = compact
    sort = priority
    show_left = true
    show_right = false
    show_line_num = true
    show_status_bar = true
    show_done = false
    show_future = false
  '';
}
