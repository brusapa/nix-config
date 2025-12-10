{ config, ... }:
let
  vars = {
    backup-directory = "/zstorage/internal-backups/paperless";
  };
in
{

  # Import the needed secrets
  sops = {
    secrets = {
      "paperless/admin-email" = {
        sopsFile = ../secrets.yaml;
      };
      "paperless/admin-password" = {
        sopsFile = ../secrets.yaml;
      };
      "paperless/gmail-oauth-client-id" = {
        sopsFile = ../secrets.yaml;
      };
      "paperless/gmail-oauth-client-secret" = {
        sopsFile = ../secrets.yaml;
      };
    };
    templates."paperless-secrets.env" = {
      content = ''
        PAPERLESS_ADMIN_MAIL="${config.sops.placeholder."paperless/admin-email"}"
        PAPERLESS_GMAIL_OAUTH_CLIENT_ID="${config.sops.placeholder."paperless/gmail-oauth-client-id"}"
        PAPERLESS_GMAIL_OAUTH_CLIENT_SECRET="${config.sops.placeholder."paperless/gmail-oauth-client-secret"}"
      '';
    };
  };

  # Create backup directory if it does not exist
  systemd.tmpfiles.rules = [
    "d ${vars.backup-directory} 0755 paperless paperless -"
  ];

  services.paperless = {
    enable = true;
    dataDir = "/zstorage/paperless";
    settings = {
      PAPERLESS_ADMIN_USER = "bruno";
      PAPERLESS_OCR_LANGUAGE = "spa+eus+eng";
      PAPERLESS_URL = "https://documentos.brusapa.com";
    };
    passwordFile = config.sops.secrets."paperless/admin-password".path;
    environmentFile = config.sops.templates."paperless-secrets.env".path;
    exporter = {
      enable = true;
      onCalendar = "daily";
      directory = vars.backup-directory;
      settings = {
        no-color = true;
        no-progress-bar = true;
      };
    };
  };

  myservices.reverseProxy.hosts.documentos.httpPort = config.services.paperless.port;

  backup-offsite-landabarri.job.paperless = {
    paths = [
      vars.backup-directory
    ];
  };
}
