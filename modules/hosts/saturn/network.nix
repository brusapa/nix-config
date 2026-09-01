{
  den.aspects.saturn.nixos = {
    systemd.network = {
      wait-online = {
        anyInterface = false;
        extraArgs = [
          "--interface=eno1"
          "--interface=iotVlan"
          "--interface=cctvVlan"
        ];
      };
      config.networkConfig = {
        IPv4Forwarding = true;
      };
      links = {
        "10-eno1" = {
          matchConfig.MACAddress = "d8:43:ae:2a:f8:10";
          linkConfig.Name = "eno1";
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
        "10-eno1" = {
          matchConfig.Name = "eno1";
          networkConfig = {
            DHCP = "yes";
            VLAN = [
              "iotVlan"
              "cctvVlan"
            ];
          };
        };

        "20-iotVlan-net" = {
          matchConfig.Name = "iotVlan";
          networkConfig = {
            DHCP = "yes";
          };
          dhcpV4Config.UseRoutes = false; # Do not use this interfaces for internet access
        };

        "21-cctvVlan-net" = {
          matchConfig.Name = "cctvVlan";
          networkConfig = {
            DHCP = "yes";
          };
          dhcpV4Config.UseRoutes = false; # Do not use this interfaces for internet access
        };
      };
    };
  };
}
