{ lib, pkgs, ... }:

{

  services.remmina = {
    enable = true;
    systemdService.enable = false;
  };

}