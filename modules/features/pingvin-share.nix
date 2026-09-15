{ den, ...}:
{
  den.aspects.pingvinShare = {
    includes = [
      den.aspects.reverse-proxy
    ];

    nixos = { lib, config, ...}: 
    let
      inherit (lib) mkOption types;
      cfg = config.pingvinShare;
      version = "v1.22.1";
      port = 8721;
    in {
      options.pingvinShare = {
        dataPath = mkOption {
          type = types.path;
          default = "/var/lib/pingvin-share";
          description = "Path to store the data";
        };
      };

      config = {

        users.groups.pingvin = { };
        users.users.pingvin = {
          group = "pingvin";
          isSystemUser = true;
        };

        # Ensure directories exist with sane permissions
        systemd.tmpfiles.rules = [
          "d ${cfg.dataPath} 0775 pingvin pingvin -"
          "d ${cfg.dataPath}/data 0775 pingvin pingvin -"
          "d ${cfg.dataPath}/data/images 0775 pingvin pingvin -"
        ];

        virtualisation.oci-containers.containers.pingvin-share = {
          image = "ghcr.io/smp46/pingvin-share-x:${version}";

          volumes = [
            "${cfg.dataPath}/data:/opt/app/backend/data"
            "${cfg.dataPath}/data/images:/opt/app/frontend/public/img"
          ];

          environment = {
            TZ = "Europe/Madrid";
            PUID = toString config.users.users.pingvin.uid;
            PGID = toString config.users.groups.pingvin.gid;
            TRUST_PROXY = "true";
            CADDY_DISANBLED = "true";
          };

          ports = [
            "${toString port}:3000/tcp"
          ];
        };
        
        reverseProxy.hosts.share.httpPort = port;
      };
    };
  };
}