{ config, ... }:
let
  vars = {
    config-path = "/var/lib/profilarr";
    port = 6868;
    version = "latest";
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
    image = "santiagosayshey/profilarr:${vars.version}";

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

}
