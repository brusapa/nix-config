{
  den.aspects.pangolin-server.nixos =
    { config, lib, ... }:
    {
      options.pangolinServer = {
        baseDomain = lib.mkOption {
          type = lib.types.str;
          default = "external.brusapa.com";
          description = "Base domain for reverse proxy";
        };
      };

      config = {
        # Import the needed secrets
        sops = {
          secrets = {
            "pangolin-server/server-secret" = { };
            "pangolin-server/cloudflare-token" = { };
          };
          templates."pangolin-server-secrets.env" = {
            content = ''
              SERVER_SECRET=${config.sops.placeholder."pangolin-server/server-secret"}
            '';
          };
          templates."traefik-secrets.env" = {
            content = ''
              CLOUDFLARE_DNS_API_TOKEN=${config.sops.placeholder."pangolin-server/cloudflare-token"}
            '';
          };
        };

        services.pangolin = {
          enable = true;
          openFirewall = true;
          dnsProvider = "cloudflare";
          letsEncryptEmail = "brusapa@brusapa.com";
          baseDomain = config.pangolinServer.baseDomain;
          environmentFile = config.sops.templates."pangolin-server-secrets.env".path;
          settings = {
            flags.enable_integration_api = true;
            domains.domain1 = {
              prefer_wildcard_cert = true;
              cert_resolver = "letsencrypt";
            };
          };
        };

        services.traefik.environmentFiles = [
          config.sops.templates."traefik-secrets.env".path
        ];
      };
    };
}
