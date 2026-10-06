{ den, ... }:
{
  den.aspects.atticd = {

    includes = [
      den.aspects.reverse-proxy
      den.aspects.postgresql
    ];

    nixos =
      { config, ... }:
      let
        port = 6732;
        # Public name served by Pangolin on pluto. The LAN DNS resolves it to
        # this host, so serve it here too and skip the trip through Pangolin.
        externalDomain = "attic.external.brusapa.com";
      in
      {
        sops.secrets."atticd/rsa-secret" = { };
        sops.templates."atticd-secrets.env".content = ''
          ATTIC_SERVER_TOKEN_RS256_SECRET_BASE64=${config.sops.placeholder."atticd/rsa-secret"}
        '';

        services.postgresql = {
          ensureDatabases = [ "atticd" ];
          ensureUsers = [
            {
              name = "atticd";
              ensureDBOwnership = true;
            }
          ];
        };

        services.atticd = {
          enable = true;
          environmentFile = config.sops.templates."atticd-secrets.env".path;
          settings = {
            listen = "[::]:${toString port}";
            #api-endpoint = "https://attic.${config.reverseProxy.baseDomain}";
            database.url = "postgresql:///atticd?host=/run/postgresql";
            garbage-collection.default-retention-period = "6 months";
          };
        };

        reverseProxy.hosts.attic.httpPort = port;

        security.acme.certs.${externalDomain}.group = config.services.caddy.group;
        services.caddy.virtualHosts.${externalDomain} = {
          useACMEHost = externalDomain;
          extraConfig = ''
            reverse_proxy http://127.0.0.1:${toString port}
          '';
        };
      };
  };
}
