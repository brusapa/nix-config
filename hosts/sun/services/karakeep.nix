{ config, ... }:
{
  # Import the needed secrets
  sops = {
    secrets = {
      "karakeep/openai-api-key" = {
        sopsFile = ../secrets.yaml;
      };
      "karakeep/oauth-client-id" = {
        sopsFile = ../secrets.yaml;
      };
      "karakeep/oauth-client-secret" = {
        sopsFile = ../secrets.yaml;
      };
    };
    templates."karakeep-secrets.env" = {
      content = ''
        OPENAI_API_KEY=${config.sops.placeholder."karakeep/openai-api-key"}
        OAUTH_CLIENT_SECRET=${config.sops.placeholder."karakeep/oauth-client-secret"}
        OAUTH_CLIENT_ID=${config.sops.placeholder."karakeep/oauth-client-id"}
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
      OAUTH_WELLKNOWN_URL = "https://pocketid.brusapa.com/.well-known/openid-configuration";
      OAUTH_PROVIDER_NAME = "PocketID";
      DISABLE_PASSWORD_AUTH = "true";
      OAUTH_ALLOW_DANGEROUS_EMAIL_ACCOUNT_LINKING = "true";
    };
    environmentFile = config.sops.templates."karakeep-secrets.env".path;
  };

  reverseProxy.hosts.karakeep.httpPort = 3000;

}
