{
  den.aspects.dispatcharr.nixos =
    { ... }:
    let
      dispatcharr-port = 9191;
      data-path = "/var/lib/dispatcharr";
    in
    {

      # Ensure directories exist with sane permissions
      systemd.tmpfiles.rules = [
        "d ${data-path} 0750 1000 1000 -"
        "d ${data-path}/data 0750 1000 1000 -"
      ];

      virtualisation.oci-containers.containers = {
        dispatcharr = {
          # update-image: ^[0-9]+\.[0-9]+\.[0-9]+$
          image = "ghcr.io/dispatcharr/dispatcharr:0.33.0";

          ports = [
            "127.0.0.1:${toString dispatcharr-port}:9191"
          ];

          volumes = [
            "${data-path}/data:/data"
          ];

          environment = {
            DISPATCHARR_ENV = "aio";
            REDIS_HOST = "localhost";
            CELERY_BROKER_URL = "redis://localhost:6379/0";
            DISPATCHARR_LOG_LEVEL = "info";
          };

          devices = [
            "/dev/dri:/dev/dri"
          ];
        };

      };

      reverseProxy.hosts.dispatcharr.httpPort = dispatcharr-port;
    };
}
