{ config, ... }:
let
  user = "romm";
  config-path = "/var/lib/romm";
  port = 7821;
  version = "latest";
  db-name = "romm";
  db-user = "romm-user";
in {

   sops = {
    secrets = {
      "romm/mariadb-root-password" = {
        sopsFile = ../secrets.yaml;
      };
      "romm/mariadb-password" = {
        sopsFile = ../secrets.yaml;
      };
      "romm/auth-secret-key" = {
        sopsFile = ../secrets.yaml;
      };
      "romm/screenscraper-user" = {
        sopsFile = ../secrets.yaml;
      };
      "romm/screenscraper-password" = {
        sopsFile = ../secrets.yaml;
      };
      "romm/retroachievements-api-key" = {
        sopsFile = ../secrets.yaml;
      };
      "romm/oidc-client-id" = {
        sopsFile = ../secrets.yaml;
      };
      "romm/oidc-client-secret" = {
        sopsFile = ../secrets.yaml;
      };
    };
    templates."romm-db-secrets.env".content = ''
      MARIADB_ROOT_PASSWORD=${config.sops.placeholder."romm/mariadb-root-password"}
      MARIADB_PASSWORD=${config.sops.placeholder."romm/mariadb-password"}
    '';
    templates."romm-secrets.env".content = ''
      DB_PASSWD=${config.sops.placeholder."romm/mariadb-password"}
      ROMM_AUTH_SECRET_KEY=${config.sops.placeholder."romm/auth-secret-key"}
      SCREENSCRAPER_USER=${config.sops.placeholder."romm/screenscraper-user"}
      SCREENSCRAPER_PASSWORD=${config.sops.placeholder."romm/screenscraper-password"}
      RETROACHIEVEMENTS_API_KEY=${config.sops.placeholder."romm/retroachievements-api-key"}
      OIDC_CLIENT_ID=${config.sops.placeholder."romm/oidc-client-id"}
      OIDC_CLIENT_SECRET=${config.sops.placeholder."romm/oidc-client-secret"}
    '';
  };

  users.groups.${user} = {};
  users.users.${user} = {
    group = user;
    isSystemUser = true;
  };

  systemd.tmpfiles.rules = [
    "d ${config-path}/config 0750 romm romm -"
    "d ${config-path}/library 0770 romm romm -"
    "d ${config-path}/assets 0750 romm romm -"
    "d ${config-path}/db 0750 romm romm -"
  ];

  virtualisation.oci-containers.containers = {
    romm-db = {
      image = "mariadb:latest";
      volumes = [
        "${config-path}/db:/var/lib/mysql"
      ];
      environment = {
        MARIADB_DATABASE=db-name;
        MARIADB_USER=db-user;
      };
      environmentFiles = [
        config.sops.templates."romm-db-secrets.env".path
      ];
    };

    romm = {
      image = "rommapp/romm:${version}";
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
        DB_NAME=db-name;
        DB_USER=db-user;
        HLTB_API_ENABLED="true";
        HASHEOUS_API_ENABLED="true";
        OIDC_ENABLED="true";
        OIDC_PROVIDER="pocketid";
        OIDC_REDIRECT_URI="https://romm.brusapa.com/api/oauth/openid";
        OIDC_SERVER_APPLICATION_URL="https://pocketid.brusapa.com/authorize";
      };
      environmentFiles = [
        config.sops.templates."romm-secrets.env".path
      ];
    };
  };

  reverseProxy.hosts.romm.httpPort = port;

}
