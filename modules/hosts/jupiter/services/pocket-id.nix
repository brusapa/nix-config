{
  den.aspects.jupiter.nixos = 
    { config, ... }:
    {
      # Import the needed secrets
      sops = {
        secrets = {
          "pocket-id/encryption-key" = {
            sopsFile = ../secrets.yaml;
          };
        };
        templates."pocket-id-secrets.env" = {
          content = ''
            ENCRYPTION_KEY=${config.sops.placeholder."pocket-id/encryption-key"}
          '';
        };
      };

      services.pocket-id = {
        enable = true;
        environmentFile = config.sops.templates."pocket-id-secrets.env".path;
        settings = {
          ANALYTICS_DISABLED = true;
          TRUST_PROXY = true;
          APP_URL = "https://pocketid.leioa.brusapa.com";
        };
      };

      reverseProxy.hosts.pocketid.httpPort = 1411;
    };
}