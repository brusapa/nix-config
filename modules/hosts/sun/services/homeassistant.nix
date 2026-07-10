{ den, ... }:
{
  den.aspects.sun = {
    includes = [
      den.aspects.mqtt
      den.aspects.matter-server
      den.aspects.influxdb
      den.aspects.glances
      den.aspects.music-assistant
    ];

    nixos = 
      { config, ... }:
      let
        vars = {
          homeassistant = {
            version = "2026.7";
            port = 8123;
          };
          zigbee2mqtt = {
            version = "2.8.0";
            port = 8081;
            trastero-port = 8082;
          };
          esphome.version = "2026.6";
        };
      in
      {
        # Import the needed secrets
        sops = {
          secrets = {
            "influxdb/homeassistant-token" = {
              owner = "influxdb2";
            };
          };
        };

        virtualisation.oci-containers.containers = {
          homeassistant = {
            volumes = [ 
              "homeassistant:/config" 
              "/zstorage/internal-backups/home-assistant:/config/backups"
            ];
            environment.TZ = "Europe/Madrid";
            image = "ghcr.io/home-assistant/home-assistant:${vars.homeassistant.version}";
            extraOptions = [
              "--network=host"
              "--cap-add=net_admin"
              "--cap-add=net_raw"
            ];
          };

          zigbee2mqtt = {
            volumes = [
              "/var/lib/home-assistant/zigbee2mqtt:/app/data"
            ];
            environment.TZ = "Europe/Madrid";
            # Note: The image will not be updated on rebuilds, unless the version label changes
            image = "ghcr.io/koenkk/zigbee2mqtt:${vars.zigbee2mqtt.version}";
            ports = [ 
              "${toString vars.zigbee2mqtt.port}:8080" # Zigbee2MQTT web interface
            ];
          };

          zigbee2mqtt-trastero = {
            volumes = [
              "/var/lib/home-assistant/zigbee2mqtt-trastero:/app/data"
            ];
            environment.TZ = "Europe/Madrid";
            image = "ghcr.io/koenkk/zigbee2mqtt:${vars.zigbee2mqtt.version}";
            ports = [
              "${toString vars.zigbee2mqtt.trastero-port}:8080"
            ];
          };

          esphome = {
            environment.TZ = "Europe/Madrid";
            volumes = [
              "/var/lib/esphome:/config"
            ];
            image = "ghcr.io/esphome/esphome:${vars.esphome.version}";
            extraOptions = [
              "--network=host"
            ];
          };
        };

        services.matter-server.extraArgs = { "primary-interface" = "iotVlan"; };

        # DB for historic data
        services.influxdb2.provision.organizations = {
          homeassistant = {
            description = "Home assistant organization";
            buckets.history = {
              description = "Historic data from home assistant";
              retention = 31536000; # 1 year
            };
            auths.homeassistant-token = {
              writeBuckets = ["history"];
              tokenFile = config.sops.secrets."influxdb/homeassistant-token".path;
            };
          };
        };

        reverseProxy.hosts = {
          casa.httpPort = 8123;
          zigbee2mqtt.httpPort = vars.zigbee2mqtt.port;
          zigbee2mqtt-trastero.httpPort = vars.zigbee2mqtt.trastero-port;
          esphome.httpPort = config.services.esphome.port;
        };

        # TODO: Preparar alternativa a backup
        # backup-offsite-landabarri.job.home-assistant = {
        #   paths = [
        #     "/zstorage/backups/home-assistant"
        #     "/var/lib/home-assistant/zigbee2mqtt"
        #     "/var/lib/home-assistant/zigbee2mqtt-trastero"
        #   ];
        # };
      };
  };
}
