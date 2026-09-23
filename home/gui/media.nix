{ pkgs, ... }:
{
  home.packages = with pkgs; [
    pavucontrol
    playerctl
    pulsemixer
  ];

  programs.mpv = {
    enable = true;
    scripts = [ pkgs.mpvScripts.mpris ];
  };

  services.playerctld.enable = true;
}
