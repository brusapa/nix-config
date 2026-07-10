{
  den.aspects.sun.nixos = 
    { lib, config, ... }:
    let
      service-name = "qbittorrent";
      config-path = "/var/lib/${service-name}";
      version = "5.2.2";
      webui-port = 18080;
      downloadPath = "/zstorage/media/torrents";
      temporalDownloadPath = "/mnt/internalBackup/downloads/torrent";
    in {
      users.users.${service-name} = {
        group = "media";
        isSystemUser = true;
        uid = 976;
      };

      systemd.tmpfiles.rules = [
        "d ${config-path} 0750 ${service-name} media -"
        "d ${downloadPath} 0755 ${service-name} media"
        "d ${temporalDownloadPath} 0755 ${service-name} media"
      ];

      virtualisation.oci-containers.containers = {
        servarr-vpn = {
          ports = lib.mkAfter [ "${toString webui-port}:${toString webui-port}/tcp" ];
          environment = {
            VPN_PORT_FORWARDING_UP_COMMAND = ''
              /bin/sh -c 'wget -O- -nv --retry-connrefused --post-data "json={\"listen_port\":{{PORT}},\"current_network_interface\":\"{{VPN_INTERFACE}}\",\"random_port\":false,\"upnp\":false}" http://127.0.0.1:${toString webui-port}/api/v2/app/setPreferences'
            '';
            VPN_PORT_FORWARDING_DOWN_COMMAND = ''
              /bin/sh -c 'wget -O- -nv --retry-connrefused --post-data "json={\"listen_port\":0,\"current_network_interface\":\"lo\"}" http://127.0.0.1:${toString webui-port}/api/v2/app/setPreferences'
            '';
          };
        };

        ${service-name} = {
          image = "lscr.io/linuxserver/qbittorrent:${version}";

          volumes = [
            "${config-path}:/config"
            "${downloadPath}:/downloads"
            "${temporalDownloadPath}:/incoming"
          ];

          environment = {
            TZ   = "Europe/Madrid";
            PUID = toString config.users.users.${service-name}.uid;
            PGID = toString config.users.groups.media.gid;
            WEBUI_PORT = "${toString webui-port}";
          };

          dependsOn = [ "servarr-vpn" ];

          extraOptions = [
            "--network=container:servarr-vpn"
          ];
        };
      };

      reverseProxy.hosts.${service-name}.httpPort = webui-port;
    };
}
