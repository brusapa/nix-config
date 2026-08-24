{ den, ... }:
{
  den.aspects.prowlarr = {
    includes = [
      den.aspects.reverse-proxy
    ];

    nixos =
      { config, ... }:
      {
        # Import the needed secrets
        sops = {
          secrets = {
            "servarr/prowlarr/apikey" = { };
          };
          templates."prowlarr-secrets.env" = {
            content = ''
              PROWLARR__AUTH__APIKEY=${config.sops.placeholder."servarr/prowlarr/apikey"}
            '';
          };
        };

        services.prowlarr = {
          enable = true;
          environmentFiles = [
            config.sops.templates."prowlarr-secrets.env".path
          ];
        };

        reverseProxy.hosts.prowlarr.httpPort = config.services.prowlarr.settings.server.port;
      };
  };
}
