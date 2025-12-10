{ lib, config, ... }:
let
  inherit (lib) mkIf mkOption  mkEnableOption types;
  cfg = config.myservices.mosquitto;
in
{
  options.myservices.mosquitto = {
    enable = mkEnableOption "Enable mosquitto";

    name = mkOption {
      type = types.str;
      default = "mosquitto";
    };

    version = mkOption {
      type = types.str;
      default = "latest";
    };

    port = mkOption {
      type = types.port;
      default = 8080;
    };
  };

  config = mkIf cfg.enable {

    virtualisation.oci-containers.containers.${cfg.name} = {
      volumes = [
        "${cfg.name}-config:/config"
      ];
      environment.TZ = "Europe/Madrid";
      image = "ghcr.io/koenkk/mosquitto:${cfg.version}";

      ports = [ 
        "${toString cfg.port}:8080/tcp"
      ];
    };

    myservices.reverseProxy.hosts.${cfg.name}.httpPort = cfg.port;

  };
}
