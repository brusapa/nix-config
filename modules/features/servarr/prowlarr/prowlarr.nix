{ den, ... }:
{
  den.aspects.prowlarr = {
    includes = [
      den.aspects.reverse-proxy
    ];

    nixos =
      { config, pkgs, ... }:
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

        # Instalar la definición personalizada de Torrentio
        systemd.services.prowlarr.preStart = ''
          ${pkgs.coreutils}/bin/mkdir -p \
            /var/lib/prowlarr/Definitions/Custom

          ${pkgs.coreutils}/bin/ln -sfn \
            ${./torrentio.yml} \
            /var/lib/prowlarr/Definitions/Custom/torrentio.yml
        '';

        reverseProxy.hosts.prowlarr.httpPort = config.services.prowlarr.settings.server.port;
      };
  };
}
