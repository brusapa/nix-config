{ lib, config, ... }:
let
  inherit (lib) mkOption  mkEnableOption types;
in
{
  options.myservices.homeAssistant = mkOption {
    type = types.attrsOf (types.submodule ({ name, ... }: {
      options = {
        enable = mkEnableOption "Enable this Home Assistant instance";

        version = mkOption {
          type = types.str;
          default = "latest";
        };

        port = mkOption {
          type = types.port;
          default = 8123;
        };

        domain = mkOption {
          type = types.str;
          example = "casa.brusapa.com";
          description = "Domain for this Home Assistant instance";
        };

        backupPath = mkOption {
          type = types.nullOr types.path;
          default = null;
          description = "Host path for backups (null disables backups)";
        };

        enableShellyCoIoT = mkOption {
          type = types.bool;
          default = false;
          description = "Expose UDP 5683 for Shelly CoIoT and open it in the firewall.";
        };
      };
    }));

    default = { };
    description = "Multiple Home Assistant service instances";
  };

  config = let
    instances =
      lib.filterAttrs (_: v: v.enable) config.myservices.homeAssistant;
  in {
    virtualisation.oci-containers.containers =
      lib.mapAttrs'
        (name: cfg: {
          name = name;
          value = {
            volumes =
              [ "${name}-config:/config" ]
              ++ lib.optional (cfg.backupPath != null)
                "${toString cfg.backupPath}:/config/backups";

            environment.TZ = "Europe/Madrid";
            image = "ghcr.io/home-assistant/home-assistant:${cfg.version}";

            ports =
              [ "${toString cfg.port}:8123/tcp" ]
              ++ lib.optional cfg.enableShellyCoIoT "5683:5683/udp";
          };
        })
        instances;

    networking.firewall.allowedUDPPorts =
      lib.flatten (
        lib.mapAttrsToList (_: cfg:
          lib.optional cfg.enableShellyCoIoT 5683
        ) instances
      );

    services.caddy.virtualHosts =
      lib.mapAttrs'
        (_: cfg: {
          name = cfg.domain;
          value.extraConfig = ''
            reverse_proxy http://localhost:${toString cfg.port}
          '';
        })
        instances;
  };
}
