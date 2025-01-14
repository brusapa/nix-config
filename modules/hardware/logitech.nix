{ pkgs, ... }:

{

  hardware.logitech.wireless.enable = true;
  hardware.logitech.wireless.enableGraphical = true;


  environment.systemPackages = [
    pkgs.piper
  ];

  services.ratbagd.enable = true;
}