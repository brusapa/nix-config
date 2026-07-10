{
  den.aspects.sun.nixos =
    { config, ... }:
    let
      vars = {
        config-path = "/var/lib/profilarr";
        port = 6868;
      };
    in {

      users.groups.profilarr = {};
      users.users.profilarr = {
        group = "profilarr";
        isSystemUser = true;
      };

      systemd.tmpfiles.rules = [
        "d ${vars.config-path} 0750 profilarr profilarr -"
      ];

      virtualisation.oci-containers.containers.profilarr = {
        image = "ghcr.io/dictionarry-hub/profilarr:2.0.9";

        volumes = [
          "${vars.config-path}:/config"
        ];

        ports = [
          "${toString vars.port}:6868"
        ];

        environment = {
          TZ = "Europe/Madrid";
          PUID = toString config.users.users.profilarr.uid;
          PGID = toString config.users.groups.profilarr.gid;
        };
      };

      reverseProxy.hosts.profilarr.httpPort = vars.port;

    };
}
