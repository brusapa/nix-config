{ config, ... }:
{
  # Import the needed secrets
  sops = {
    secrets = {
      "mealie/oidc-client-id" = {
        sopsFile = ../secrets.yaml;
      };
      "mealie/oidc-client-secret" = {
        sopsFile = ../secrets.yaml;
      };
    };
    templates."mealie-secrets.env" = {
      content = ''
        OIDC_CLIENT_ID=${config.sops.placeholder."mealie/oidc-client-id"}
        OIDC_CLIENT_SECRET=${config.sops.placeholder."mealie/oidc-client-secret"}
      '';
    };
  };

  services.mealie = {
    enable = true;
    port = 9623;
    database.createLocally = true;
    credentialsFile = config.sops.templates."mealie-secrets.env".path;
    settings = {
      BASE_URL = "https://recetas.brusapa.com";
      SMTP_HOST = "127.0.0.1";
      SMTP_PORT = 25;
      SMTP_AUTH_STRATEGY = "NONE";
      SMTP_FROM_NAME = "Recetas";
      SMTP_FROM_EMAIL = "recetas@brusapa.com";
      OIDC_AUTH_ENABLED = true;
      OIDC_SIGNUP_ENABLED = true;
      OAUTH_PROVIDER_NAME = "Pocket ID";
      OIDC_CONFIGURATION_URL = "https://pocketid.brusapa.com/.well-known/openid-configuration";
    };
  };

  reverseProxy.hosts.recetas.httpPort = config.services.mealie.port;
}