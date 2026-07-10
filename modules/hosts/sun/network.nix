{
  den.aspects.sun.nixos = {
    systemd.network = {
      config.networkConfig = {
        IPv4Forwarding = true;
        IPv6Forwarding = true;
      };
      links = {
        "10-lan1s1g" = {
          matchConfig.MACAddress = "9c:6b:00:45:80:66";
          linkConfig.Name = "lan1s1g";
        };
        "10-lan2s1g" = {
          matchConfig.MACAddress = "9c:6b:00:45:80:67";
          linkConfig.Name = "lan2s1g";
        };
        "10-lan3s10g" = {
          matchConfig.MACAddress = "9c:6b:00:45:80:68";
          linkConfig.Name = "lan3s10g";
        };
        "10-lan4s10g" = {
          matchConfig.MACAddress = "9c:6b:00:45:80:69";
          linkConfig.Name = "lan4s10g";
        };
      };

      netdevs = {
        "20-iotVlan" = {
          netdevConfig = {
            Kind = "vlan";
            Name = "iotVlan";
            MACAddress = "02:11:22:33:44:55";
          };
          vlanConfig = {
            Id = 2;
          };
        };
        "21-cctvVlan" = {
          netdevConfig = {
            Kind = "vlan";
            Name = "cctvVlan";
            MACAddress = "02:11:22:33:44:56";
          };
          vlanConfig = {
            Id = 3;
          };
        };
      };

      networks = {
        "10-lan2s1g" = {
          matchConfig.Name = "lan2s1g";
          networkConfig = {
            DHCP = "yes";
            IPv6AcceptRA = true;
            VLAN = [ "iotVlan" "cctvVlan" ]; 
          };
        };

        # Not used network interfaces, forced to down
        "15-lan-others" = {
          matchConfig.Name = "lan1s1g lan3s10g lan4s10g";
          linkConfig.ActivationPolicy = "down";
        };

        "20-iotVlan-net" = {
          matchConfig.Name = "iotVlan";
          networkConfig = {
            DHCP = "yes";
            IPv6AcceptRA = true;
          };
          dhcpV4Config.UseRoutes = false; # Do not use this interfaces for internet access
        };

        "21-cctvVlan-net" = {
          matchConfig.Name = "cctvVlan";
          networkConfig = {
            DHCP = "yes";
            IPv6AcceptRA = true;
          };
          dhcpV4Config.UseRoutes = false; # Do not use this interfaces for internet access
        };
      };
    };
  };
}