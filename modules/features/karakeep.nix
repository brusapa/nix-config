{ den, ... }:
{
  den.aspects.karakeep = {
    includes = [
      den.aspects.reverse-proxy
    ];

    nixos = 
      { config, ... }:
      let
        port = 3000;
      in 
      {
        # Import the needed secrets
        sops = {
          secrets = {
            "karakeep/openai-api-key" = {};
            "karakeep/oauth-client-id" = {};
            "karakeep/oauth-client-secret" = {};
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
            PORT = toString port;
            NEXTAUTH_URL = "https://karakeep.${config.reverseProxy.baseDomain}";
            DISABLE_NEW_RELEASE_CHECK = "true";
            OCR_LANGS = "eng,spa";
            OAUTH_WELLKNOWN_URL = "https://pocketid.${config.reverseProxy.baseDomain}/.well-known/openid-configuration";
            OAUTH_PROVIDER_NAME = "PocketID";
            DISABLE_PASSWORD_AUTH = "true";
            OAUTH_ALLOW_DANGEROUS_EMAIL_ACCOUNT_LINKING = "true";
          };
          environmentFile = config.sops.templates."karakeep-secrets.env".path;
        };

        reverseProxy.hosts.karakeep.httpPort = port;

      };
  };
}
