{ pkgs, ... }:
{
  programs.yazi = {
    enable = true;
    package = pkgs.yazi;

    enableBashIntegration = false;
    enableFishIntegration = false;
    enableNushellIntegration = true;
    enableZshIntegration = false;
    shellWrapperName = "yy";

    extraPackages = with pkgs; [
      exiftool
      mediainfo
    ];

    settings = {
      mgr = {
        show_hidden = true;
        mouse_events = [
          "click"
          "scroll"
        ];
        title_format = "Yazi: {cwd}";
      };

      preview.sixel_fraction = 15;

      opener = {
        edit = [
          {
            run = "\${EDITOR:-vi} %s";
            desc = "$EDITOR";
            block = true;
            "for" = "unix";
          }
        ];
        open = [
          {
            run = "xdg-open %s1";
            desc = "Open";
            "for" = "linux";
          }
        ];
        reveal = [
          {
            run = "xdg-open %d1";
            desc = "Reveal";
            "for" = "linux";
          }
          {
            run = "clear; exiftool %s1; echo 'Press enter to exit'; read _";
            desc = "Show EXIF";
            block = true;
            "for" = "unix";
          }
        ];
        play = [
          {
            run = "mpv --force-window %s";
            orphan = true;
            "for" = "unix";
          }
          {
            run = "mediainfo %s1; echo 'Press enter to exit'; read _";
            desc = "Show media info";
            block = true;
            "for" = "unix";
          }
        ];
      };

      tasks.image_bound = [
        0
        0
      ];

      plugin.prepend_previewers = [
        {
          url = "*/";
          run = "folder";
          sync = true;
        }
      ];
    };
  };
}
