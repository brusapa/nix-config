{ den, ... }:
{
  den.hosts.x86_64-linux.saturn = {
    role = "server";
    users.bruno = { };
    swapSizeGiB = 32;
  };

  den.aspects.saturn = {
    includes = [
      # Role
      den.aspects.server

      # Other features
      den.aspects.reverse-proxy
      den.aspects.acme
      den.aspects.containers
      den.aspects.zfs
      den.aspects.tailscale-server
      den.aspects.mqtt
      den.aspects.zigbee2mqtt
      den.aspects.home-assistant
      den.aspects.frigate

      # Hardware
      den.aspects.intel-cpu
      den.aspects.apcupsd
    ];

    nixos = {
      # Unique host identifier used for ZFS
      networking.hostId = "51a04533";

      sops.defaultSopsFile = ./secrets.yaml;

      reverseProxy.baseDomain = "sonabia.brusapa.com";

      # Home assistant
      mqtt.domain = "mqtt.sonabia.brusapa.com";
      zigbee2mqtt = {
        zigbeecasa.port = 8080;
        zigbeegaraje.port = 8081;
      };

      # Frigate
      frigate = {
        hwaccel-driver = "iHD";
        media-path = "/zsonabia/frigate";
      };
    };
  };
}
