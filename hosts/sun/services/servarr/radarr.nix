{ config, ... }:
{
  # Import the needed secrets
  sops = {
    secrets = {
      "servarr/radarr/apikey" = {
        sopsFile = ../../secrets.yaml;
      };
    };
    templates."radarr-secrets.env" = {
      content = ''
        READARR__AUTH__APIKEY=${config.sops.placeholder."servarr/radarr/apikey"}
      '';
    };
  };

  services.radarr = {
    enable = true;
    group = "media";
    environmentFiles = [
      config.sops.templates."radarr-secrets.env".path
    ];
  };

  services.caddy.virtualHosts."radarr.brusapa.com".extraConfig = ''
    reverse_proxy http://localhost:${toString config.services.radarr.settings.server.port}
  '';
}