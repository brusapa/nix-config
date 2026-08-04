{ den, ... }:
{
  den.aspects.sonarr = {
    includes = [
      den.aspects.reverse-proxy
    ];

    nixos =
      { config, ... }:
      {
        # Import the needed secrets
        sops = {
          secrets = {
            "servarr/sonarr/apikey" = { };
          };
          templates."sonarr-secrets.env" = {
            content = ''
              SONARR__AUTH__APIKEY=${config.sops.placeholder."servarr/sonarr/apikey"}
            '';
          };
        };

        services.sonarr = {
          enable = true;
          group = "media";
          environmentFiles = [
            config.sops.templates."sonarr-secrets.env".path
          ];
        };

        reverseProxy.hosts.sonarr.httpPort = config.services.sonarr.settings.server.port;

      };
  };
}
