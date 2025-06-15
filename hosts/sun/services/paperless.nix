{ config, ... }:
{

  # Import the needed secrets
  sops = {
    secrets = {
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
        PAPERLESS_GMAIL_OAUTH_CLIENT_ID="${config.sops.placeholder."paperless/gmail-oauth-client-id"}"
        PAPERLESS_GMAIL_OAUTH_CLIENT_SECRET="${config.sops.placeholder."paperless/gmail-oauth-client-secret"}"
      '';
    };
  };

  services.paperless = {
    enable = true;
    dataDir = "/zstorage/paperless";
    settings = {
      PAPERLESS_OCR_LANGUAGE = "spa+eus+eng";
      PAPERLESS_URL = "https://documentos.brusapa.com";
    };
    passwordFile = config.sops.secrets."paperless/admin-password".path;
    environmentFile = config.sops.templates."paperless-secrets.env".path;
  };
  services.caddy.virtualHosts."documentos.brusapa.com".extraConfig = ''
    reverse_proxy http://127.0.0.1:28981
  '';
}
