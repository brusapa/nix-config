{ config, ... }:
{
  # Import the needed secrets
  sops = {
    secrets = {
      "servarr/sonarr/apikey" = {
        sopsFile = ../../secrets.yaml;
      };
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

  services.caddy.virtualHosts."sonarr.brusapa.com".extraConfig = ''
    reverse_proxy http://localhost:${toString config.services.sonarr.settings.server.port}
  '';
}