{ ... }:
let 
  dispatcharr-port = 9191;
  epg-port = 9192;
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
    iptv-org-epg = {
      image = "ghcr.io/iptv-org/epg:master";

      ports = [
        "${toString epg-port}:3000"
      ];

      volumes = [
        "epg_data:/epg"
      ];

      environment = {
        MAX_CONNECTIONS = "50";
        DAYS = "14";
      };
    };

  };

  reverseProxy.hosts.dispatcharr.httpPort = dispatcharr-port;
  reverseProxy.hosts.epg.httpPort = epg-port;
}
