{
  den.aspects.sun-disabled.nixos =
    { ... }:
    let
      dispatcharr-port = 9191;
    in
    {

      virtualisation.oci-containers.containers = {
        dispatcharr = {
          # update-image: ^[0-9]+\.[0-9]+\.[0-9]+$
          image = "ghcr.io/dispatcharr/dispatcharr:0.31.0";

          ports = [
            "127.0.0.1:${toString dispatcharr-port}:9191"
          ];

          volumes = [
            "dispatcharr_data:/data"
          ];

          environment = {
            DISPATCHARR_ENV = "aio";
            REDIS_HOST = "localhost";
            CELERY_BROKER_URL = "redis://localhost:6379/0";
            DISPATCHARR_LOG_LEVEL = "info";
          };
        };

      };

      reverseProxy.hosts.dispatcharr.httpPort = dispatcharr-port;
    };
}
