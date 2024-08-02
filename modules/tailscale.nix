{ inputs, lib, config, pkgs, ... }:

{

  services.tailscale.enable = true;
  services.tailscale.openFirewall = true;

}