{
  pkgs,
  lib,
  config,
  ...
}:
{
  home.packages = [ pkgs.swaynotificationcenter ];

  xdg.configFile = {
    "swaync/config.json".text =
      lib.replaceStrings
        [ "/home/piioni/.config/hypr/scripts/logout.sh" ]
        [ "${config.xdg.configHome}/hypr/scripts/logout.sh" ]
        (builtins.readFile ./swaync/config.json);

    "swaync/style.css".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/home/piioni/swaync/style.css";
    "swaync/icons/airplane-mode-off.png".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/home/piioni/swaync/icons/airplane-mode-off.png";
    "swaync/icons/airplane-mode-on.png".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/home/piioni/swaync/icons/airplane-mode-on.png";
    "swaync/icons/bolt.png".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/home/piioni/swaync/icons/bolt.png";
    "swaync/icons/brightness-100.png".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/home/piioni/swaync/icons/brightness-100.png";
    "swaync/icons/brightness-20.png".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/home/piioni/swaync/icons/brightness-20.png";
    "swaync/icons/brightness-40.png".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/home/piioni/swaync/icons/brightness-40.png";
    "swaync/icons/brightness-60.png".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/home/piioni/swaync/icons/brightness-60.png";
    "swaync/icons/brightness-80.png".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/home/piioni/swaync/icons/brightness-80.png";
    "swaync/icons/gamemode.png".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/home/piioni/swaync/icons/gamemode.png";
    "swaync/icons/microphone-mute.png".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/home/piioni/swaync/icons/microphone-mute.png";
    "swaync/icons/microphone.png".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/home/piioni/swaync/icons/microphone.png";
    "swaync/icons/music.png".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/home/piioni/swaync/icons/music.png";
    "swaync/icons/palette.png".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/home/piioni/swaync/icons/palette.png";
    "swaync/icons/picture.png".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/home/piioni/swaync/icons/picture.png";
    "swaync/icons/play.png".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/home/piioni/swaync/icons/play.png";
    "swaync/icons/timer.png".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/home/piioni/swaync/icons/timer.png";
    "swaync/icons/volume-high.png".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/home/piioni/swaync/icons/volume-high.png";
    "swaync/icons/volume-low.png".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/home/piioni/swaync/icons/volume-low.png";
    "swaync/icons/volume-mid.png".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/home/piioni/swaync/icons/volume-mid.png";
    "swaync/icons/volume-mute.png".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/home/piioni/swaync/icons/volume-mute.png";
    "swaync/icons/wand.png".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/home/piioni/swaync/icons/wand.png";
  };
}
