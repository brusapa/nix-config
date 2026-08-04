{ den, ... }:
{
  den.aspects.seerr = {
    includes = [
      den.aspects.reverse-proxy
    ];
    nixos = { config, ... }: {
      services.seerr.enable = true;
      reverseProxy.hosts.seerr.httpPort = config.services.seerr.port;
    };
  };
}
