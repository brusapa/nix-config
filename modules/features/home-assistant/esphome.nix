{ den, ... }: {
  den.aspects.esphome = {
    includes = [
      den.aspects.reverse-proxy
    ];

    nixos = { config, ... }: {
      services.esphome = {
        enable = true;
      };

      reverseProxy.hosts.esphome.httpPort = config.services.esphome.port;
    };
  };
}
