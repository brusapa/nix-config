{ config, ... }:
{
  # Import the needed secrets
  sops = {
    secrets = {
      "vaultwarden/smtp-from-email" = {
        sopsFile = ../secrets.yaml;
      };
      "vaultwarden/admin-token" = {
        sopsFile = ../secrets.yaml;
      };
    };
    templates."vaultwarden-secrets.env" = {
      content = ''
        ADMIN_TOKEN=${config.sops.placeholder."vaultwarden/admin-token"}
        SMTP_FROM=${config.sops.placeholder."vaultwarden/smtp-from-email"}
      '';
    };
  };

  services.vaultwarden = {
    enable = true;
    config = {
      DOMAIN = "https://bitwarden.brusapa.com";
      SIGNUPS_ALLOWED = false;
      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = 8222;
      ROCKET_LOG = "critical";
      SMTP_HOST = "127.0.0.1";
      SMTP_PORT = 25;
      SMTP_SSL = false;
      SMTP_FROM_NAME = "Bitwarden server";
    };
    environmentFile = config.sops.templates."vaultwarden-secrets.env".path;
    backupDir = "/zstorage/internal-backups/vaultwarden";
  };


  reverseProxy.hosts.bitwarden.httpPort = config.services.vaultwarden.config.ROCKET_PORT;

  backup-offsite-landabarri.job.vaultwarden = {
    paths = [
      "/zstorage/internal-backups/vaultwarden"
    ];
  };
}
