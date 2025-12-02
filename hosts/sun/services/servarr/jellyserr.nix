{ config, ... }:
{
  # Import the needed secrets
  sops = {
    secrets = {
      "servarr/jellarr/apikey" = {
        sopsFile = ../../secrets.yaml;
      };
    };
    templates."jellarr-secrets.env" = {
      content = ''
        JELLARR_API_KEY=${config.sops.placeholder."servarr/sonarr/apikey"}
      '';
    };
  };

  services.jellyserr = {
    enable = true;
    group = "media";
    environmentFiles = [
      config.sops.templates."jellyserr-secrets.env".path
    ];
  };

  services.jellarr = {
    enable = true;
    user = "jellyfin";
    group = "media";
    environmentFile = config.sops.templates."jellarr-secrets.env".path;
    config = {
      base_url = "http://localhost:8096";
      system.enableMetrics = true;
    };
  };

  services.caddy.virtualHosts."jellyserr.brusapa.com".extraConfig = ''
    reverse_proxy http://localhost:${toString config.services.jellyserr.port}
  '';
}