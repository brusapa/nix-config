{
  den.aspects.tailscale-client.nixos = {
    services.tailscale = {
      enable = true;
      openFirewall = true;
      useRoutingFeatures = "client";
    };
  };
}
