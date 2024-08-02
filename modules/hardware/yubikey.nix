{ inputs, lib, config, pkgs, ... }:

{

  services.udev.packages = [ pkgs.yubikey-personalization ];

}