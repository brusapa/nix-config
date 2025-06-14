{ config, ... }:
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
  
  services.restic.backups.immich = {
    repository = "/mnt/internalBackup/immich";
    passwordFile = config.sops.secrets.backup-password.path;
    initialize = true;

    backupPrepareCommand = ''
      systemctl stop immich-server.service immich-machine-learning.service
      sudo -u postgres pg_dump immich > /zstorage/photos/database-backup/immich.sql
      systemctl start immich-server.service immich-machine-learning.service
    '';

    paths = [ 
      "/zstorage/photos" 
    ];

    exclude = [
      "/backups"
      "/encoded-video"
    ];

    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
    };

    pruneOpts = [
      "--keep-daily 7"
      "--keep-monthly 12"
    ];
  };
}
