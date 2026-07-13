{ den, ... }:
{
  den.aspects.glances = {
    includes = [
      den.aspects.reverse-proxy
    ];
    nixos = { config, ... }: {
      services.glances = {
        enable = true;
      };

      reverseProxy.hosts.glances.httpPort = config.services.glances.port;
    };
  };
}
