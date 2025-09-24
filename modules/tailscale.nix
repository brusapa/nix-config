{ inputs, lib, config, pkgs, ... }:

{

  services.tailscale = {
    enable = true;
    openFirewall = true;
  };

}
