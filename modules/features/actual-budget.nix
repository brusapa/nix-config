{den, ... }:
{
  den.aspects.actual-budget = {
    includes = [
      den.aspects.reverse-proxy
    ];
    nixos = { config, ... }: {
      users.groups.actual = { };
      users.users.actual = {
        group = "actual";
        isSystemUser = true;
      };

      # Import the needed secrets
      sops = {
        secrets = {
          "actual-budget/pocketid-client-id".owner = "actual";
          "actual-budget/pocketid-client-secret".owner = "actual";
        };
      };

      services.actual = {
        enable = true;
        user = "actual";
        group = "actual";
        settings = {
          port = 5006;
          openId = {
            discoveryURL = "https://pocketid.${config.reverseProxy.baseDomain}";
            client_id._secret = config.sops.secrets."actual-budget/pocketid-client-id".path;
            client_secret._secret = config.sops.secrets."actual-budget/pocketid-client-secret".path;
            server_hostname = "https://actual.${config.reverseProxy.baseDomain}";
            authMethod = "openid";
          };
        };
      };

      reverseProxy.hosts.actual.httpPort = config.services.actual.settings.port;
    };
  };
}