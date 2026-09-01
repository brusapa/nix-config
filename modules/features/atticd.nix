{ den, ... }:
{
  den.aspects.atticd = {
    
    includes = [
      den.aspects.reverse-proxy
      den.aspects.postgresql
    ];

    nixos = { config, ... }: 
    let
      port = 6732;
    in {
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
    };
  };
}
