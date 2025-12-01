{ config, pkgs, ... }:
let
  vars = {
    homeassistant = {
      version = "2025.11";
      port = 8123;
    };
    zigbee2mqtt = {
      version = "2.6.3";
      port = 8081;
      trastero-port = 8082;
    };
    mosquitto = {
      version = "2.0.22";
    };
  };
in
{
  # Import the needed secrets
  sops = {
    secrets = {
      "influxdb/admin-password" = {
        sopsFile = ../secrets.yaml;
        owner = "influxdb2";
      };
      "influxdb/admin-token" = {
        sopsFile = ../secrets.yaml;
        owner = "influxdb2";
      };
      "influxdb/homeassistant-token" = {
        sopsFile = ../secrets.yaml;
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

    mosquitto = {
      volumes = [
        "/var/lib/home-assistant/mosquitto/config:/mosquitto/config" 
        "mosquitto-data:/mosquitto/data"
      ];
      environment.TZ = "Europe/Madrid";
      # Note: The image will not be updated on rebuilds, unless the version label changes
      image = "eclipse-mosquitto:${vars.mosquitto.version}";
      ports = [ 
        "1883:1883"
        "9001:9001"
      ];
    };
  };

  # Glances for homeassistant monitoring of the server
  services.glances = {
    enable = true;
  };

  # EspHome 
  services.esphome = {
    enable = false;
  };

  # DB for historic data
  services.influxdb2 = {
    enable = true;
    provision = {
      enable = true;
      initialSetup = {
        organization = "main";
        bucket = "main";
        passwordFile = config.sops.secrets."influxdb/admin-password".path;
        tokenFile = config.sops.secrets."influxdb/admin-token".path;
      };
      organizations = {
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
    };
  };

  services.caddy.virtualHosts."influxdb.brusapa.com".extraConfig = ''
    reverse_proxy http://localhost:8086
  '';

  services.caddy.virtualHosts."glances.brusapa.com".extraConfig = ''
    reverse_proxy http://127.0.0.1:${toString config.services.glances.port}
  '';
  services.caddy.virtualHosts."casa.brusapa.com".extraConfig = ''
    reverse_proxy http://127.0.0.1:8123
  '';
  services.caddy.virtualHosts."zigbee2mqtt.brusapa.com".extraConfig = ''
    reverse_proxy http://127.0.0.1:${toString vars.zigbee2mqtt.port}
  '';
  services.caddy.virtualHosts."zigbee2mqtt-trastero.brusapa.com".extraConfig = ''
    reverse_proxy http://127.0.0.1:${toString vars.zigbee2mqtt.trastero-port}
  '';

  services.caddy.virtualHosts."esphome.brusapa.com".extraConfig = ''
    reverse_proxy http://127.0.0.1:${toString config.services.esphome.port}
  '';

  backup-offsite-landabarri.job.home-assistant = {
    paths = [
      "/zstorage/backups/home-assistant"
      "/var/lib/home-assistant/zigbee2mqtt"
      "/var/lib/home-assistant/zigbee2mqtt-trastero"
    ];
  };

  nixpkgs =  {
    # Set ctranslate2 cuda support
    overlays = [
      (final: prev: {
        ctranslate2 = prev.ctranslate2.override {
          withCUDA = true;
          withCuDNN = true;
        };
      })
    ];
  };

  environment.systemPackages = with pkgs; [
    python3Packages.pytorch-bin
    whisper-ctranslate2
  ];

  services.wyoming.faster-whisper.servers.homeassistant = {
    enable = true;
    device = "cuda";
    uri = "tcp://0.0.0.0:10300";
    model = "medium";
    language = "es";
  };
  services.wyoming.piper.servers.homeassistant = {
    enable = true;
    voice = "es_ES-mls_10246-low";
    uri = "tcp://0.0.0.0:10200";
  };

}
