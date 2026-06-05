{ ... }:
let
  service-name = "serr";
  config-path = "/var/lib/${service-name}";
  port = 5055;
  version = "v3.0.1";
in {

  systemd.tmpfiles.rules = [
    "d ${config-path} 0750 1000 1000 -"
  ];

  virtualisation.oci-containers.containers.${service-name} = {
    image = "ghcr.io/seerr-team/seerr:${version}";

    volumes = [
      "${config-path}:/app/config"
    ];

    ports = [
      "${toString port}:5055"
    ];

    environment = {
      TZ = "Europe/Madrid";
    };
  };

  reverseProxy.hosts.serr.httpPort = port;
}
