{ config, ... }:
let 
  version = "2.2.16";
  port = 7490;
  dataPath = "/var/lib/miniflux";
  subdomain = "rss";
in 
{

  systemd.tmpfiles.rules = [
    "d ${dataPath} 0775 root root -"
  ];

  # Import the needed secrets
  sops = {
    secrets = {
      "miniflux/pocketid-client-id" = {
        sopsFile = ../secrets.yaml;
      };
      "miniflux/pocketid-client-secret" = {
        sopsFile = ../secrets.yaml;
      };
      "miniflux/db-password" = {
        sopsFile = ../secrets.yaml;
      };
    };
    templates = {
      "miniflux-secrets.env" = {
        content = ''
          OAUTH2_CLIENT_ID=${config.sops.placeholder."miniflux/pocketid-client-id"}
          OAUTH2_CLIENT_SECRET=${config.sops.placeholder."miniflux/pocketid-client-secret"}
          DATABASE_URL=postgres://miniflux:${config.sops.placeholder."miniflux/db-password"}@miniflux-db/miniflux?sslmode=disable
        '';
      };
      "miniflux-db-secrets.env" = {
        content = ''
          POSTGRES_PASSWORD=${config.sops.placeholder."miniflux/db-password"}
        '';
      };
    };
  };

  virtualisation.oci-containers.containers = {
    miniflux = {
      image = "ghcr.io/miniflux/miniflux:${version}";

      ports = [
        "${toString port}:8080"
      ];

      dependsOn = [
        "miniflux-db"
      ];

      environment = {
        BASE_URL="https://${subdomain}.brusapa.com";
        RUN_MIGRATIONS="1";
        OAUTH2_PROVIDER="oidc";
        OAUTH2_REDIRECT_URL="https://${subdomain}.brusapa.com/oauth2/oidc/callback";
        OAUTH2_OIDC_DISCOVERY_ENDPOINT="https://pocketid.brusapa.com";
        OAUTH2_OIDC_PROVIDER_NAME="PocketID";
        OAUTH2_USER_CREATION="1";
        DISABLE_LOCAL_AUTH="1";
      };

      environmentFiles = [
        config.sops.templates."miniflux-secrets.env".path
      ];
    };

    miniflux-db = {
      image = "postgres:18";

      volumes = [
        "${dataPath}:/var/lib/postgresql"
      ];

      environment = {
        POSTGRES_USER="miniflux";
        POSTGRES_DB="miniflux";
      };

      environmentFiles = [
        config.sops.templates."miniflux-db-secrets.env".path
      ];
    };
  };


  reverseProxy.hosts.${subdomain}.httpPort = port;
}