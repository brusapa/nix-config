{ lib, config, ... }:
let
  inherit (lib) mkIf mkOption  mkEnableOption types;
  cfg = config.myservices.zigbee2mqtt;
in
{
  options.myservices.zigbee2mqtt = {
    enable = mkEnableOption "Enable zigbee2mqtt";

    name = mkOption {
      type = types.str;
      default = "zigbee2mqtt";
    };

    version = mkOption {
      type = types.str;
      default = "latest";
    };

    port = mkOption {
      type = types.port;
      default = 8080;
    };

    domain = mkOption {
      type = types.str;
      default = "zigbee2mqtt.brusapa.com";
      description = "Domain for zigbee2mqtt";
    };
  };

  config = mkIf cfg.enable {

    virtualisation.oci-containers.containers.${cfg.name} = {
      volumes = [
        "${cfg.name}-config:/config"
      ];
      environment.TZ = "Europe/Madrid";
      image = "ghcr.io/koenkk/zigbee2mqtt:${cfg.version}";

      ports = [ 
        "${toString cfg.port}:8080/tcp"
      ];
    };

    reverseProxy.hosts.${cfg.name}.httpPort = cfg.port;

  };
}
