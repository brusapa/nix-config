
{ den, ... }:
{
  den.aspects.home-assistant = {
    includes = [
      den.aspects.reverse-proxy
    ];
    nixos = 
      { lib, config, ... }:
      let
        inherit (lib) mkOption types;
        cfg = config.home-assistant;
      in
      {
        options.home-assistant = {
          subdomain = mkOption {
            type = types.str;
            default = "casa";
            example = "casa";
            description = "Subdomain for this Home Assistant instance";
          };

          backupPath = mkOption {
            type = types.nullOr types.path;
            default = null;
            description = "Host path for backups (null disables backups)";
          };
        };

        config = {

          virtualisation.oci-containers.containers.home-assistant = {
            volumes =
              [ "home-assistant-config:/config" ]
              ++ lib.optional (cfg.backupPath != null)
                "${toString cfg.backupPath}:/config/backups";

            environment.TZ = "Europe/Madrid";
            image = "ghcr.io/home-assistant/home-assistant:2026.7.1";

            extraOptions = [ "--network=host" ];

            capabilities = {
              NET_ADMIN = true;
              NET_RAW = true;
            };

          };

          reverseProxy.hosts.${cfg.subdomain}.httpPort = 8123;
        };
      };
  };
}

