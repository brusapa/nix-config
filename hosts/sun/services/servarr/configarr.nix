{ config, ... }:
let
  config-path = "/var/lib/configarr/config";
  version = "1.18";
in {

  users.groups.configarr = {};
  users.users.configarr = {
    group = "configarr";
    isSystemUser = true;
  };

  systemd.tmpfiles.rules = [
    "d ${config-path} 0750 configarr configarr -"
  ];

  virtualisation.oci-containers.containers.configarr = {
    image = "ghcr.io/raydak-labs/configarr:${version}";
    user = "${config.users.users.configarr.name}:${config.users.users.configarr.group}";

    volumes = [
      "${config-path}:/app/config"
    ];

    environment = {
      TZ   = "Europe/Madrid";
      # PUID = toString config.users.users.configarr.uid;
      # PGID = toString config.users.groups.configarr.gid;
    };
  };
}
