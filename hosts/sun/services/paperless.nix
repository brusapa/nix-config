{ config, ... }:
{

  # Import the needed secrets
  sops = {
    secrets = {
      paperless-admin-password = {
        sopsFile = ../secrets.yaml;
      };
    };
  };

  services.paperless = {
    enable = true;
    dataDir = "/zstorage/paperless";
    settings = {
      PAPERLESS_OCR_LANGUAGE = "spa+eus+eng";
      PAPERLESS_URL = "https://documentos.brusapa.com";
    };
    passwordFile = config.sops.secrets.paperless-admin-password.path;
  };
  services.caddy.virtualHosts."documentos.brusapa.com".extraConfig = ''
    reverse_proxy http://127.0.0.1:28981
  '';
}
