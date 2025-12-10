{ config, ... }:
{
  # Import the needed secrets
  sops = {
    secrets = {
      "karakeep/openai-api-key" = {
        sopsFile = ../secrets.yaml;
      };
    };
    templates."karakeep-secrets.env" = {
      content = ''
        OPENAI_API_KEY=${config.sops.placeholder."karakeep/openai-api-key"}
      '';
    };
  };

  services.karakeep = {
    enable = true;
    extraEnvironment = {
      PORT = "3000";
      NEXTAUTH_URL = "https://karakeep.brusapa.com";
      DISABLE_NEW_RELEASE_CHECK = "true";
      OCR_LANGS = "eng,spa";
    };
    environmentFile = config.sops.templates."karakeep-secrets.env".path;
  };

  myservices.reverseProxy.hosts.karakeep.httpPort = 3000;

}
