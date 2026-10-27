{
  den.aspects.tailscale-client.nixos = { config, lib, ... }: {
    services.tailscale = {
      enable = true;
      openFirewall = true;
      useRoutingFeatures = lib.mkDefault "client";
    };

    networking.firewall = {
      # Always allow traffic from your Tailscale network
      trustedInterfaces = [ config.services.tailscale.interfaceName ];
      # Allow the Tailscale UDP port through the firewall
      allowedUDPPorts = [ config.services.tailscale.port ];
    };

    # Force tailscaled to use nftables (Critical for clean nftables-only systems)
    # This avoids the "iptables-compat" translation layer issues.
    systemd.services.tailscaled.serviceConfig.Environment = [
      "TS_DEBUG_FIREWALL_MODE=nftables"
    ];
  };
}
