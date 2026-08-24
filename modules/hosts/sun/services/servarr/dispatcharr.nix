{
  den.aspects.sun.nixos =
    { ... }:
    let
      dispatcharr-port = 9191;
    in
    {

      virtualisation.oci-containers.containers = {
        dispatcharr = {
          image = "ghcr.io/dispatcharr/dispatcharr";

          ports = [
            "${toString dispatcharr-port}:9191"
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
