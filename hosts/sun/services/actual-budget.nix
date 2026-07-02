{ config, ... }:
{
  users.groups.actual = { };
  users.users.actual = {
    group = "actual";
    isSystemUser = true;
  };

  # Import the needed secrets
  sops = {
    secrets = {
      "actual-budget/pocketid-client-id" = {
        sopsFile = ../secrets.yaml;
        owner = "actual";
      };
      "actual-budget/pocketid-client-secret" = {
        sopsFile = ../secrets.yaml;
        owner = "actual";
      };
    };
  };

  services.actual = {
    enable = true;
    user = "actual";
    group = "actual";
    settings = {
      port = 5006;
      openId = {
        discoveryURL = "https://pocketid.brusapa.com";
        client_id._secret = config.sops.secrets."actual-budget/pocketid-client-id".path;
        client_secret._secret = config.sops.secrets."actual-budget/pocketid-client-secret".path;
        server_hostname = "https://actual.brusapa.com";
        authMethod = "openid";
      };
    };
  };

  reverseProxy.hosts.actual.httpPort = config.services.actual.settings.port;
}