{ den, ... }:
{
  den.aspects.immich = {
  
    includes = [
      den.aspects.reverse-proxy
    ];

    nixos = 
      { config, lib, ... }:
      {
        # Import the needed secrets
        sops = {
          secrets = {
            "immich/pocketid-client-id" = {
              owner = config.services.immich.user;
            };
            "immich/pocketid-client-secret" = {
              owner = config.services.immich.user;
            };
          };
        };

        services.immich = {
          enable = true;
          mediaLocation = lib.mkDefault null;
          settings = {
            server = {
              externalDomain = "https://fotos.${config.reverseProxy.baseDomain}";
            };
            storageTemplate = {
              enabled = true;
              hashVerificationEnabled = true;
              template = "{{y}}/{{#if album}}{{album}}{{else}}Other{{/if}}/{{filename}}";
            };
            notifications = {
              smtp = {
                enabled = true;
                from = "fotos@${config.reverseProxy.baseDomain}";
                transport = {
                  host = "127.0.0.1";
                  port = 25;
                };
              };
            };
            oauth = {
              enabled = true;
              buttonText = "Login with PocketID";
              clientId._secret = config.sops.secrets."immich/pocketid-client-id".path;
              clientSecret._secret = config.sops.secrets."immich/pocketid-client-secret".path;
              issuerUrl = "https://pocketid.${config.reverseProxy.baseDomain}";
            };
          };
          accelerationDevices = null; # Give access to all devices
        };

        users.users.${config.services.immich.user}.extraGroups = [ "video" "render" ];

        reverseProxy.hosts.fotos = {
          ip = "localhost";
          httpPort = config.services.immich.port;
        };
      };
  };
}
