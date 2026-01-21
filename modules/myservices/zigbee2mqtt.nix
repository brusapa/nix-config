{ lib, config, ... }:
let
  inherit (lib) mkIf mkOption  mkEnableOption types;
  cfg = config.zigbee2mqtt;
in
{
  options.zigbee2mqtt = mkOption {
    type = types.attrsOf (types.submodule ({ name, ...}: {
      options = {
        enable = mkEnableOption "Enable zigbee2mqtt";

        version = mkOption {
          type = types.str;
          default = "latest";
        };

        port = mkOption {
          type = types.port;
          default = 8080;
        };

        subdomain = mkOption {
          type = types.str;
          default = "zigbee2mqtt";
          description = "Domain for zigbee2mqtt";
        };
      };
    }));

    default = {};
    description = "Zigbee2MQTT instances";
  };

  config = {
    virtualisation.oci-containers.containers =
      lib.mapAttrs'
        (name: inst:
          lib.nameValuePair name {
            image = "ghcr.io/koenkk/zigbee2mqtt:${inst.version}";

            volumes = [
              "${name}-data:/app/data"
            ];

            environment = {
              TZ = "Europe/Madrid";
            };

            ports = [
              "${toString inst.port}:8080/tcp"
            ];
          }
        )
        (lib.filterAttrs (_: inst: inst.enable) cfg);

    reverseProxy.hosts =
      lib.mkMerge (
        lib.mapAttrsToList
          (_name: inst:
            lib.mkIf inst.enable {
              ${inst.subdomain} = {
                httpPort = inst.port;
              };
            }
          )
          cfg
      );
  };
}
