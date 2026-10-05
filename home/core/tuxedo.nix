{ pkgs, ... }:
{
  # webstonehq/tuxedo, a todo.txt TUI; nixpkgs' tuxedo-rs is unrelated TUXEDO hardware tooling.
  home.packages = [ (pkgs.callPackage ../../packages/tuxedo.nix { }) ];

  xdg.configFile."tuxedo/config.toml".text = ''
    # tuxedo's own key = value format, not TOML.
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
