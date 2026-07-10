{ den, ... }:
{
  den.aspects.dawarich = {
    includes = [
      den.aspects.reverse-proxy
    ]; 
    nixos =
      { config, ... }:
      {
        # Import the needed secrets
        sops = {
          secrets = {
            "dawarich/secret-key" = { };
            "dawarich/pocketid-client-id" = { };
            "dawarich/pocketid-client-secret" = { };
          };
          templates."dawarich-secrets.env" = {
            content = ''
              OIDC_CLIENT_ID=${config.sops.placeholder."dawarich/pocketid-client-id"}
              OIDC_CLIENT_SECRET=${config.sops.placeholder."dawarich/pocketid-client-secret"}
            '';
          };
        };

        services.dawarich = {
          enable = true;
          localDomain = "dawarich.${config.reverseProxy.baseDomain}";
          webPort = 7863;
          configureNginx = false;
          smtp = {
            host = "127.0.0.1";
            fromAddress = "dawarich@${config.reverseProxy.baseDomain}";
          };
          secretKeyBaseFile = config.sops.secrets."dawarich/secret-key".path;
          environment = {
            OIDC_PROVIDER_NAME = "PocketId";
            OIDC_AUTO_REGISTER = "true";
            ALLOW_EMAIL_PASSWORD_REGISTRATION = "false";
            OIDC_ISSUER = "https://pocketid.${config.reverseProxy.baseDomain}";
            OIDC_REDIRECT_URI = "https://dawarich.${config.reverseProxy.baseDomain}/users/auth/openid_connect/callback";
          };
          extraEnvFiles = [
            config.sops.templates."dawarich-secrets.env".path
          ];
        };

        reverseProxy.hosts.dawarich.httpPort = config.services.dawarich.webPort;
      };
  };
}