{ den, ... }:
{
  den.aspects.healthchecks = {
    includes = [
      den.aspects.reverse-proxy
    ];
    nixos =
      { config, ... }:
      let
        port = 12137;
      in
      {
        # Import the needed secrets
        sops = {
          secrets = {
            "healthchecks/secret-key" = {
              owner = config.services.healthchecks.user;
            };
            "ntfy/healthchecks-token" = {
              owner = config.services.healthchecks.user;
            };
          };
        };

        services.healthchecks = {
          enable = true;
          port = port;
          settings = {
            ADMINS = "brusapa@brusapa.com";
            SECRET_KEY_FILE = config.sops.secrets."healthchecks/secret-key".path;
            NTFY_SH_TOKEN_FILE = config.sops.secrets."ntfy/healthchecks-token".path;
            DEFAULT_FROM_EMAIL = "healthchecks@brusapa.com";
            EMAIL_HOST = "127.0.0.1";
            EMAIL_PORT = "25";
            EMAIL_USE_TLS = "False";
          };
        };

        reverseProxy.hosts.healthchecks.httpPort = port;
      };
  };
}
