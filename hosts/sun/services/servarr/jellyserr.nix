{ config, ... }:
{
  services.jellyserr = {
    enable = true;
    group = "media";
    environmentFiles = [
      config.sops.templates."jellyserr-secrets.env".path
    ];
  };

  reverseProxy.hosts.jellyserr.httpPort = config.services.jellyserr.port;
}