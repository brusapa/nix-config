{ lib, config, ... }:
let
  inherit (lib) mkIf mkOption  mkEnableOption types;
  cfg = config.wallaos;
in
{
  options.wallaos = {
    enable = mkEnableOption "Enable wallaos";

    name = mkOption {
      type = types.str;
      default = "wallaos";
    };

    version = mkOption {
      type = types.str;
      default = "latest";
    };

    port = mkOption {
      type = types.port;
      default = 8282;
    };

    domain = mkOption {
      type = types.str;
      default = "wallaos.brusapa.com";
      description = "Domain for wallaos";
    };
  };

  config = mkIf cfg.enable {

    virtualisation.oci-containers.containers.${cfg.name} = {
      volumes = [
        "wallaos-${cfg.name}-db:/var/www/html/db"
        "wallaos-${cfg.name}-logos:/var/www/html/images/uploads/logos"
      ];
      environment.TZ = "Europe/Madrid";
      image = "bellamy/wallos:${cfg.version}";

      ports = [ 
        "${toString cfg.port}:80/tcp"
      ];
    };

    reverseProxy.hosts.${cfg.name}.httpPort = cfg.port;

  };
}
