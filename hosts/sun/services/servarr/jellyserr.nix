{ config, ... }:
{
  services.jellyserr = {
    enable = true;
    group = "media";
    environmentFiles = [
      config.sops.templates."jellyserr-secrets.env".path
    ];
  };

  services.caddy.virtualHosts."jellyserr.brusapa.com".extraConfig = ''
    reverse_proxy http://localhost:${toString config.services.jellyserr.port}
  '';
}