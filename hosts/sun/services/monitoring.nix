{ config, ... }:
{

  sops.secrets = {
    "grafana/admin-email" = {
      sopsFile = ../secrets.yaml;
      owner = "grafana";
    };
    "grafana/admin-password" = {
      sopsFile = ../secrets.yaml;
      owner = "grafana";
    };
  };

  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "127.0.0.1";
        http_port = 3101;
        domain = "grafana.brusapa.com";
      };
      security = {
        admin_user = "bruno";
        admin_email = "$__file{${config.sops.secrets."grafana/admin-email".path}}";
        admin_password = "$__file{${config.sops.secrets."grafana/admin-password".path}}";
      };
      smtp.enabled = true;
    };
    provision = {
      enable = true;
      datasources.settings = {

        datasources = [{
          name = "Prometheus";
          type = "prometheus";
          url = "http://localhost:9090";
        }];

        deleteDatasources = [{
          name = "Prometheus";
          orgId = 1;
        }];
      };
    };
  };

  services.prometheus = {
    enable = true;
    exporters = {
      node = {
        enable = true;
        enabledCollectors = [ "systemd" ];
      };
      apcupsd.enable = true;
      postgres.enable = true;
    };
    scrapeConfigs = [
      {
        job_name = "sun_statistics";
        static_configs = [{
          targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.node.port}" ];
        }];
      }
      {
        job_name = "apcupsd";
        static_configs = [{
          targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.apcupsd.port}" ];
        }];
      }
    ];
  };


  reverseProxy.hosts.grafana.httpPort = config.services.grafana.settings.server.http_port;

}
