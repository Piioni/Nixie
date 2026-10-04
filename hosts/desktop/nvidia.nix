{
  config,
  lib,
  ...
}:
{
  # Base NVIDIA para Wayland/Niri.
  services.xserver.videoDrivers = [ "nvidia" ];

  # Recomendado para sesiones Wayland en NVIDIA.
  boot.kernelParams = [
    "nvidia-drm.modeset=1"
    "nvidia-drm.fbdev=1"
  ];

  hardware.graphics = {
    enable = true;
    # util para apps/juegos que aun requieren librerias de 32 bits
    enable32Bit = true;
  };

  hardware.nvidia = {
    # Similar a idols-ai: preferir modulo abierto en GPUs compatibles.
    open = lib.mkDefault true;
    modesetting.enable = true;
    nvidiaSettings = true;
    powerManagement.enable = lib.mkDefault true;

    # Evita "latest + patches" para un MVP y usa rama estable/production.
    package = lib.mkDefault config.boot.kernelPackages.nvidiaPackages.production;
  };

  # Si luego usas CUDA en contenedores:
  # hardware.nvidia-container-toolkit.enable = true;
}
