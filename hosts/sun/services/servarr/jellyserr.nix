{ config, ... }:
{
  services.jellyserr = {
    enable = true;
    group = "media";
    environmentFiles = [
      config.sops.templates."jellyserr-secrets.env".path
    ];
  };

  myservices.reverseProxy.hosts.jellyserr.httpPort = config.services.jellyserr.port;
}