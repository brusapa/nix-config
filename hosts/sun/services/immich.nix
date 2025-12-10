{ config, pkgs, ... }:
let
  vars = {
    backup-directory = "/zstorage/internal-backups/immich";
  };
in
{
  # Import the needed secrets
  sops = {
    secrets = {
      backup-password = {
        sopsFile = ../secrets.yaml;
      };
    };
  };

  services.immich = {
    enable = true;
    mediaLocation = "/zstorage/photos";
    settings = {
      server = {
        externalDomain = "https://fotos.brusapa.com";
      };
      storageTemplate = {
        enabled = true;
        hashVerificationEnabled = true;
        template = "{{y}}/{{#if album}}{{album}}{{else}}Other{{/if}}/{{filename}}";
      };
      notifications = {
        smtp = {
          enabled = true;
          from = "fotos@brusapa.com";
          transport = {
            host = "127.0.0.1";
            port = 25;
          };
        };
      };
    };
    accelerationDevices = [
      "/dev/dri/renderD128"
    ];
  };

  myservices.reverseProxy.hosts.fotos = {
    ip = "localhost";
    httpPort = config.services.immich.port;
  };

  # Backup Immich database
  systemd.tmpfiles.rules = [
    "d ${vars.backup-directory} 0755 postgres postgres 30d"
  ];
  systemd.services.immich-db-backup = {
    description = "Backup Immich DB safely";
    serviceConfig = {
      Type = "oneshot";
      User = "postgres";
      # This makes it run as postgres just for the pg_dump
      ExecStart = [
        "${pkgs.bash}/bin/bash -c '${pkgs.postgresql}/bin/pg_dump immich > ${vars.backup-directory}/immich-db-$(date +%%Y%%m%%d-%%H%%M%%S).sql'"
      ];
    };
  };
  systemd.timers.immich-db-backup = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      Unit = "immich-db-backup.service";
    };
  };

  backup-offsite-landabarri.job.immich = {
    paths = [
      "/zstorage/photos"
      vars.backup-directory
    ];
    exclude = [
      "/zstorage/photos/backups"
      "/zstorage/photos/encoded-video"
    ];
    backupPrepareCommand = ''
      systemctl stop immich-server.service immich-machine-learning.service
      systemctl start immich-db-backup.service
      systemctl start immich-server.service immich-machine-learning.service
    '';
  };
}
