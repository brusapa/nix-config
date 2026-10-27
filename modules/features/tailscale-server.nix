{ den, ... }:
{
  den.aspects.tailscale-server = {
    includes = [
      den.aspects.tailscale-client
    ];

    nixos = {
      services.tailscale = {
        extraSetFlags = [ "--advertise-exit-node" ];
        useRoutingFeatures = "server";
      };

      networking.firewall = {
        # https://wiki.nixos.org/wiki/Tailscale#No_internet_when_using_exit_node
        checkReversePath = "loose";
      };
    };
  };
}
