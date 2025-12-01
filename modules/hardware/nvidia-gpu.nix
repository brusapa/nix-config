{ lib, ... }:
{
  # Nvidia
  services.xserver.videoDrivers = lib.mkDefault [ "nvidia" ];
  nixpkgs.config.cudaSupport = true;
  hardware.nvidia = {
    open = true;
  };

  # CUDA cache
  nix.settings = {
    substituters = lib.mkAfter [
      "https://cache.flox.dev"
      "https://cache.nixos-cuda.org"
    ];
    trusted-public-keys = lib.mkAfter [
      "flox-cache-public-1:7F4OyH7ZCnFhcze3fJdfyXYLQw/aV7GEed86nQ7IsOs="
      "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
    ];
  };
}