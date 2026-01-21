{ config, ... }:
{
  imports = [
    ../../../modules/myservices/frigate.nix
  ];

  frigate = {
    enable = true;
    version = "0.16.2";
    hwaccel-driver = "radeonsi";
    media-path = "/znvme/frigate";
  };
}
