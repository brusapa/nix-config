{ pkgs, ... }:

{

  services.tailscale = {
    enable = true;
    openFirewall = true;
    extraSetFlags = [ "--advertise-exit-node" ];
    useRoutingFeatures = "server";
  };

  # https://wiki.nixos.org/wiki/Tailscale#No_internet_when_using_exit_node
  networking.firewall.checkReversePath = "loose";
}
