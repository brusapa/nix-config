{ config, pkgs, ... }:
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

  # Reverse proxy
  services.caddy.virtualHosts."fotos.brusapa.com".extraConfig = ''
    reverse_proxy http://localhost:2283
  '';

  # Backups
  systemd.services.immich-db-backup = {
    description = "Backup Immich DB safely";
    serviceConfig = {
      Type = "oneshot";
      # This makes it run as postgres just for the pg_dump
      ExecStart = [
        "${pkgs.postgresql}/bin/pg_dump immich -f /zstorage/backups/immich-database/immich.sql"
      ];
      User = "postgres";
    };
  };

  backup.job.immich = {
    paths = [
      "/zstorage/photos"
      "/zstorage/backups/immich-database"
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
