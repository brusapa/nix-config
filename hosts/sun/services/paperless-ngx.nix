{ config, pkgs, ... }:
let
  base-directory = "/var/lib/paperless";
in {

  # Ensure host directories exist
  systemd.tmpfiles.rules = [
    "d /srv/paperless/export 0755 root root -"
    "d /srv/paperless/consume 0755 root root -"
  ];

  virtualisation.oci-containers.containers = {
    paperless-ngx-broker = {
      image = "docker.io/library/redis:8";

      volumes = [
        "${base-directory}/redisdata:/data"
      ];
    };

    paperless-ngx-db = {
      image = "docker.io/library/postgres:18";

      environment = {
        POSTGRES_DB = "paperless";
        POSTGRES_USER = "paperless";
        POSTGRES_PASSWORD = "paperless";
      };

      volumes = [
        "${base-directory}/pgdata:/var/lib/postgresql"
      ];
    };

    paperless-ngx-gotenberg = {
      image = "docker.io/gotenberg/gotenberg:8.25";

      cmd = [
        "gotenberg"
        "--chromium-disable-javascript=true"
        "--chromium-allow-list=file:///tmp/.*"
      ];
    };

    paperless-ngx-tika = {
      image = "docker.io/apache/tika:latest";
    };

    paperless-ngx-webserver = {
      image = "ghcr.io/paperless-ngx/paperless-ngx:latest";

      ports = [
        "8000:8000"
      ];

      dependsOn = [
        "paperless-ngx-db"
        "paperless-ngx-broker"
        "paperless-ngx-gotenberg"
        "paperless-ngx-tika"
      ];

      environmentFiles = [
        /etc/paperless/docker-compose.env
      ];

      environment = {
        PAPERLESS_REDIS = "redis://paperless-ngx-broker:6379";
        PAPERLESS_DBHOST = "paperless-ngx-db";
        PAPERLESS_TIKA_ENABLED = "1";
        PAPERLESS_TIKA_GOTENBERG_ENDPOINT = "http://paperless-ngx-gotenberg:3000";
        PAPERLESS_TIKA_ENDPOINT = "http://paperless-ngx-tika:9998";
      };

      volumes = [
        "${base-directory}/data:/usr/src/paperless/data"
        "${base-directory}/media:/usr/src/paperless/media"
        "/srv/paperless/export:/usr/src/paperless/export"
        "/srv/paperless/consume:/usr/src/paperless/consume"
      ];
    };
  };
}
