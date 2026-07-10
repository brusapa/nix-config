{
  den.aspects.matter-server.nixos = {
    services.matter-server = {
      enable = true;
      openFirewall = true;
    };
    # Open mDNS on firewall for the matter server
    networking.firewall = {
      allowedUDPPorts = [ 5353 ];
      # Crucial for mDNS / Multicast on Linux firewalls
      extraCommands = ''
        # Allow incoming multicast traffic for mDNS
        iptables -A INPUT -d 224.0.0.251 -p udp --dport 5353 -j ACCEPT
        ip6tables -A INPUT -d ff02::fb -p udp --dport 5353 -j ACCEPT

        # Allow Matter link-local multicast
        ip6tables -A INPUT -d ff02::1 -p udp -j ACCEPT
      '';
    };
  };
}