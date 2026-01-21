{ lib, config, ... }:
let
  inherit (lib) mkOption  mkEnableOption types mkIf;
  cfg = config.home-assistant;
in
{
  options.home-assistant = {
    enable = mkEnableOption "Enable Home Assistant";

    version = mkOption {
      type = types.str;
      default = "latest";
    };

    port = mkOption {
      type = types.int;
      default = 8123;
    };

    subdomain = mkOption {
      type = types.str;
      example = "casa";
      description = "Subdomain for this Home Assistant instance";
    };

    backupPath = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "Host path for backups (null disables backups)";
    };
  };

  config = mkIf cfg.enable {

    virtualisation.oci-containers.containers.home-assistant = {
      volumes =
        [ "home-assistant-config:/config" ]
        ++ lib.optional (cfg.backupPath != null)
          "${toString cfg.backupPath}:/config/backups";

      environment.TZ = "Europe/Madrid";
      image = "ghcr.io/home-assistant/home-assistant:${cfg.version}";

      capabilities = {
        NET_ADMIN = true;
        NET_RAW = true;
      };

      ports = [
        "${toString cfg.port}:8123/tcp"
      ];
    };

    reverseProxy.hosts.${cfg.subdomain}.httpPort = cfg.port;
  };
}
