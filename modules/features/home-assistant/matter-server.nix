{
  den.aspects.matter-server.nixos = {
    services.matter-server = {
      enable = true;
      openFirewall = true;
    };
    # Open mDNS on firewall for the matter server
    networking.firewall.allowedUDPPorts = [ 5353 ];
  };
}
