{ lib, config, ... }:
let
  inherit (lib) mkIf mkOption  mkEnableOption types;
  cfg = config.donetick;
in
{
  options.donetick = {
    enable = mkEnableOption "Enable donetick";

    version = mkOption {
      type = types.str;
      default = "latest";
    };

    port = mkOption {
      type = types.port;
      default = 2021;
    };

    environment = mkOption {
      type = types.attrsOf types.str;
      default = { };
      description = "Environment variables to set for this container.";
    };

    environmentFiles = mkOption {
      type = types.listOf lib.types.path;
      default = [];
      description = "Extra environment files to pass to donetick";
    };
  };

  config = mkIf cfg.enable {

    virtualisation.oci-containers.containers.donetcik = {
      volumes = [
        "donetick-data:/donetick-data"
        "donetick-config:/config"
      ];
      environment = {
        TZ = "Europe/Madrid";
        DT_ENV="selfhosted";
        DT_DATABASE_TYPE="sqlite";
        DT_SQLITE_PATH="/donetick-data/donetick.db";
      } 
      // cfg.environment;
      image = "donetick/donetick:${cfg.version}";
      ports = [ 
        "${toString cfg.port}:2021/tcp"
      ];
      environmentFiles = cfg.environmentFiles;
    };

  };
}
