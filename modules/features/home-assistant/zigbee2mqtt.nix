{ den, ... }:
{
  den.aspects.zigbee2mqtt = {
    includes = [
      den.aspects.reverse-proxy
    ];

    nixos =
      { lib, config, ... }:
      let
        inherit (lib) mkOption types;
        cfg = config.zigbee2mqtt;
      in
      {
        options.zigbee2mqtt = mkOption {
          type = types.attrsOf (
            types.submodule {
              options = {
                port = mkOption {
                  type = types.port;
                  default = 8080;
                };
              };
            }
          );

          default = { };
          description = "Zigbee2MQTT instances";
        };

        config = {
          virtualisation.oci-containers.containers = lib.mapAttrs' (
            name: inst:
            lib.nameValuePair name {
              image = "ghcr.io/koenkk/zigbee2mqtt:2.12.1";

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
          ) cfg;

          reverseProxy.hosts = lib.mapAttrs' (
            name: inst: lib.nameValuePair name { httpPort = inst.port; }
          ) cfg;
        };
      };
  };
}
