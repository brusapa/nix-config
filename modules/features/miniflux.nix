{ den, ... }:
{
  den.aspects.miniflux = {
    
    includes = [
      den.aspects.reverse-proxy
    ];

    nixos = { config, ... }: 
    let
      port = 6241;
    in
    {
      sops = {
        secrets = {
          "miniflux/admin-username" = { };
          "miniflux/admin-password" = { };
          "miniflux/oauth-client-id" = { };
          "miniflux/oauth-client-secret" = { };
        };
        templates."miniflux-secrets.env".content = ''
          ADMIN_USERNAME=${config.sops.placeholder."miniflux/admin-username"}
          ADMIN_PASSWORD=${config.sops.placeholder."miniflux/admin-password"}
          OAUTH2_CLIENT_ID=${config.sops.placeholder."miniflux/oauth-client-id"}
          OAUTH2_CLIENT_SECRET=${config.sops.placeholder."miniflux/oauth-client-secret"}
        '';
      };

      services.miniflux = {
        enable = true;
        adminCredentialsFile = config.sops.templates."miniflux-secrets.env".path;
        config = {
          BASE_URL = "https://miniflux.${config.reverseProxy.baseDomain}";
          PORT = toString port;
          OAUTH2_PROVIDER = "oidc";
          OAUTH2_REDIRECT_URL = "https://miniflux.${config.reverseProxy.baseDomain}/oauth2/oidc/callback";
          OAUTH2_OIDC_DISCOVERY_ENDPOINT = "https://pocketid.${config.reverseProxy.baseDomain}";
          OAUTH2_OIDC_PROVIDER_NAME = "PocketID";
          OAUTH2_USER_CREATION = "1";
          DISABLE_LOCAL_AUTH = "0";
        };
      };

      reverseProxy.hosts.miniflux.httpPort = port;
    };
  };
}
