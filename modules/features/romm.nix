{ den, ... }:
{
  den.aspects.romm = {
    includes = [
      den.aspects.reverse-proxy
    ];

    nixos = { config, ... }: 
    let
      user = "romm";
      config-path = "/var/lib/romm";
      port = 7821;
      romm-version = "5.2";
      mariadb-version = "latest";
      db-name = "romm";
      db-user = "romm-user";
    in {

      sops = {
        secrets = {
          "romm/mariadb/root-password" = {};
          "romm/mariadb/password" = {};
          "romm/auth-secret-key" = {};
          "romm/igdb/client-id" = {};
          "romm/igdb/client-secret" = {};
          "romm/steamgriddb-api-key" = {};
          "romm/retroachievements-api-key" = {};
          "romm/oidc/client-id" = {};
          "romm/oidc/client-secret" = {};
        };
        templates."romm-db-secrets.env".content = ''
          MARIADB_ROOT_PASSWORD=${config.sops.placeholder."romm/mariadb/root-password"}
          MARIADB_PASSWORD=${config.sops.placeholder."romm/mariadb/password"}
        '';
        templates."romm-secrets.env".content = ''
          DB_PASSWD=${config.sops.placeholder."romm/mariadb/password"}
          ROMM_AUTH_SECRET_KEY=${config.sops.placeholder."romm/auth-secret-key"}
          IGDB_CLIENT_ID=${config.sops.placeholder."romm/igdb/client-id"}
          IGDB_CLIENT_SECRET=${config.sops.placeholder."romm/igdb/client-secret"}
          STEAMGRIDDB_API_KEY=${config.sops.placeholder."romm/steamgriddb-api-key"}
          RETROACHIEVEMENTS_API_KEY=${config.sops.placeholder."romm/retroachievements-api-key"}
          OIDC_CLIENT_ID=${config.sops.placeholder."romm/oidc/client-id"}
          OIDC_CLIENT_SECRET=${config.sops.placeholder."romm/oidc/client-secret"}
        '';
      };

      users.groups.${user} = {};
      users.users.${user} = {
        group = user;
        isSystemUser = true;
      };

      # Ensure directories exist with sane permissions
      systemd.tmpfiles.rules = [
        "d ${config-path} 0750 ${user} ${user} -"
        "d ${config-path}/config 0750 ${user} ${user} -"
        "d ${config-path}/library 0770 ${user} ${user} -"
        "d ${config-path}/assets 0750 ${user} ${user} -"
        "d ${config-path}/db 0750 ${user} ${user} -"
      ];

      virtualisation.oci-containers.containers = {
        romm-db = {
          image = "mariadb:${mariadb-version}";
          user = "${toString config.users.users.romm.uid}:${toString config.users.groups.romm.gid}";
          volumes = [
            "${config-path}/db:/var/lib/mysql"
          ];
          environment = {
            MARIADB_DATABASE="${db-name}";
            MARIADB_USER="${db-user}";
          };
          environmentFiles = [
            config.sops.templates."romm-db-secrets.env".path
          ];
        };

        romm = {
          image = "ghcr.io/rommapp/romm:${romm-version}";
          user = "${toString config.users.users.romm.uid}:${toString config.users.groups.romm.gid}";
          dependsOn = ["romm-db"];
          volumes = [
            "romm_resources:/romm/resources"
            "romm_redis_data:/redis-data"
            "${config-path}/config:/romm/config"
            "${config-path}/library:/romm/library"
            "${config-path}/assets:/romm/assets"
          ];
          ports = [
            "${toString port}:8080"
          ];
          environment = {
            TZ = "Europe/Madrid";
            DB_HOST="romm-db";
            DB_NAME="${db-name}";
            DB_USER="${db-user}";
            HLTB_API_ENABLED="true";
            HASHEOUS_API_ENABLED="true";
            OIDC_ENABLED="true";
            OIDC_PROVIDER="pocketid";
            OIDC_REDIRECT_URI="https://romm.${config.reverseProxy.baseDomain}/api/oauth/openid";
            OIDC_SERVER_APPLICATION_URL="https://pocketid.${config.reverseProxy.baseDomain}";
          };
          environmentFiles = [
            config.sops.templates."romm-secrets.env".path
          ];
        };
      };

      reverseProxy.hosts.romm.httpPort = port;
    };
  };
}
