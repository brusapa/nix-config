{ config, ... }:
{
  # Import the needed secrets
  sops = {
    secrets = {
      "vaultwarden/smtp-from-email" = {
        sopsFile = ../secrets.yaml;
        owner = config.services.vaultwarden.user;
      };
      "vaultwarden/admin-token" = {
        sopsFile = ../secrets.yaml;
        owner = config.services.vaultwarden.user;
      };
    };
    templates."vaultwarden-secrets.env" = {
      content = ''
        ADMIN_TOKEN=${config.sops.placeholder.vaultwarden-admin-token}
        SMTP_FROM=${config.sops.placeholder.vaultwarden-smtp-from-email}
      '';
      owner = config.services.vaultwarden.user;
    };
  };

  services.vaultwarden = {
    enable = true;
    config = {
      DOMAIN = "https://passwords.brusapa.com";
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
  };

  services.caddy.virtualHosts."passwords.brusapa.com".extraConfig = ''
    reverse_proxy http://127.0.0.1:8222
  '';
}