{ den, ... }:
{
  den.aspects.vikunja = {
    includes = [
      den.aspects.reverse-proxy
    ];

    nixos = { config, ... }: {

      sops = {
        secrets = {
          "vikunja/service/secret" = {};
          "vikunja/auth/pocketid-id" = {};
          "vikunja/auth/pocketid-secret" = {};
        };
        templates."vikunja-secrets.env".content = ''
          VIKUNJA_SERVICE_SECRET=${config.sops.placeholder."vikunja/service/secret"}
          VIKUNJA_AUTH_OPENID_PROVIDERS_POCKETID_CLIENTID=${config.sops.placeholder."vikunja/auth/pocketid-id"}
          VIKUNJA_AUTH_OPENID_PROVIDERS_POCKETID_CLIENTSECRET=${config.sops.placeholder."vikunja/auth/pocketid-secret"}
        '';
      };

      services.vikunja = {
        enable = true;
        frontendHostname = "vikunja.${config.reverseProxy.baseDomain}";
        frontendScheme = "https";
        environmentFiles = [
          config.sops.templates."vikunja-secrets.env".path
        ];
        settings = {
          service = {
            enableregistration = false;
            timezone = "Europe/Madrid";
          };
          mailer = {
            enabled = true;
            host = "127.0.0.1";
            port = 25;
            fromemail = "vikunja@bruspa.com";
          };
          auth = {
            local.enabled = false;
            openid = {
              enabled = true;
              redirecturl = "https://vikunja.${config.reverseProxy.baseDomain}/auth/openid/pocketid";
              providers.POCKETID = {
                name = "PocketID";
                authurl = "https://pocketid.${config.reverseProxy.baseDomain}";
                scope = "openid profile email";
                usernamefallback = true;
                emailfallback = true;
              };
            };
          };
          defaultsettings = {
            avatar_provider = "gravatar";
            week_start = 1; #Monday
          };
        };
      };

      reverseProxy.hosts.vikunja.httpPort = config.services.vikunja.port;
    };
  };
}
