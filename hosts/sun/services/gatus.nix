{ config, lib, ... }:
{
  options.external-health-check.job = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule {
        options = {
          name = lib.mkOption {
            type = lib.types.str;
            default = "";
            description = "Name of the health-check job";
          };
          group = lib.mkOption {
            type = lib.types.str;
            default = "";
            description = "Used to group multiple health-check jobs together";
          };
          token = lib.mkOption {
            type = lib.types.str;
            default = "";
            description = "Bearer token required to push status to.";
          };
        };
      }
    );
  };

  config = {
    # Import the needed secrets
    sops = {
      secrets = {
        "gatus/notification-email" = {
          sopsFile = ../secrets.yaml;
        };
        "gatus/from-email" = {
          sopsFile = ../secrets.yaml;
        };
      };
      templates."gatus-secrets.env" = {
        content = ''
          NOTIFICATION_EMAIL=${config.sops.placeholder."gatus/notification-email"}
          FROM_EMAIL=${config.sops.placeholder."gatus/from-email"}
        '';
      };
    };

    services.gatus = {
      enable = true;
      environmentFile = config.sops.templates."gatus-secrets.env".path;
      settings = {
        ui.dark-mode = false;

        endpoints = [
          {
            name = "home-assistant";
            group = "smart-home";
            url = "https://casa.brusapa.com";
            interval = "1m";
            conditions = [
              "[STATUS] == 200"
              "[BODY] != ''"
            ];
            alerts = [
              {
                type = "email";
              }
            ];
          }
          {
            name = "zigbee2mqtt";
            group = "smart-home";
            url = "https://zigbee2mqtt.brusapa.com";
            interval = "1m";
            conditions = [
              "[STATUS] == 200"
              "[BODY] != ''"
            ];
            alerts = [
              {
                type = "email";
              }
            ];
          }
        ];

        external-endpoints =
          builtins.map
            (job: {
              name = job.name;
              group = job.group;
              token = job.token;
              alerts = [
                { 
                  type = "email"; 
                }
              ];
            })
            (builtins.attrValues config.external-health-check.job);

        alerting.email = {
          from = "\${FROM_EMAIL}";
          host = "127.0.0.1";
          port = 25;
          to = "\${NOTIFICATION_EMAIL}";
          default-alert = {
            description = "Health check failed";
            send-on-resolved = true;
            failure-threshold = 5;
            success-threshold = 5;
          };
        };

        storage = {
          type = "sqlite";
          path = "/var/lib/gatus/historic.db";
          caching = true;
        };
      };
    };

    myservices.reverseProxy.hosts.gatus.httpPort = config.services.gatus.settings.web.port;
  };
}