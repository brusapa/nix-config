{ lib, config, ... }:
let
  vars = {
    config-path = "/var/lib/jackett/.config";
    port = 9117;
    version = "0.24.372";
  };
in {

  users.groups.jackett.gid = config.ids.gids.jackett;
  users.users.jackett = {
    group = "jackett";
    home = vars.config-path;
    uid = config.ids.uids.jackett;
  };

  systemd.tmpfiles.rules = [
    "d ${vars.config-path} 0750 jackett jackett -"
  ];

  virtualisation.oci-containers.containers = {
    servarr-vpn.ports = lib.mkAfter [ "${toString vars.port}:${toString vars.port}/tcp" ];

    jackett = {
      image = "linuxserver/jackett:${vars.version}";

      volumes = [
        "${vars.config-path}:/config"
      ];

      environment = {
        TZ   = "Europe/Madrid";
        PUID = toString config.users.users.jackett.uid;
        PGID = toString config.users.groups.jackett.gid;
      };

      dependsOn = [ "servarr-vpn" ];

      extraOptions = [
        "--network=container:servarr-vpn"
      ];
    };
  };

  reverseProxy.hosts.jackett.httpPort = vars.port;

}
