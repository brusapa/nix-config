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
              CLOUDFLARE_PROPAGATION_TIMEOUT=600
              CLOUDFLARE_POLLING_INTERVAL=10
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
            # This block prevents collisions with tailscale
            gerbil = {
              subnet_group = "10.89.128.0/20";q
              block_size = 24;
              site_block_size = 30;
            };
            orgs = {
              block_size = 24;
              subnet_group = "10.90.128.0/20";
              utility_subnet_group = "10.96.128.0/20";
            };
          };
        };

        services.traefik.environmentFiles = [
          config.sops.templates."traefik-secrets.env".path
        ];
      };
    };
}
