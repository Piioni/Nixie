{ noctaliaGreeter, ... }:
{
  imports = [
    noctaliaGreeter.nixosModules.default
  ];

  programs = {
    hyprland.enable = true;
    niri.enable = true;
  };

  services.displayManager.noctalia-greeter = {
    enable = true;
    settings.keyboard.layout = "es";
  };
}
