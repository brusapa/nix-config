{ inputs, lib, config, pkgs, ... }:

{

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  }
  
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia.nvidiaSettings = true;

}