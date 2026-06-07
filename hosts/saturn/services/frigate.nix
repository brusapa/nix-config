{ config, ... }:
{
  imports = [
    ../../../modules/myservices/frigate.nix
  ];

  frigate = {
    enable = true;
    version = "0.16.2";
    hwaccel-driver = "iHD";
    media-path = "/zsonabia/frigate";
  };
}
