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
    services.gatus = {
      enable = true;
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
          # TODO: Esto mejor como secreto
          from = "gatus@brusapa.com";
          host = "127.0.0.1";
          port = 25;
          # TODO: Esto mejor como secreto
          to = "brusapa@brusapa.com";
          default-alert = {
            description = "Health check failed";
            send-on-resolved = true;
            failure-threshold = 5;
            success-threshold = 5;
          };
        };
      };
    };

    # Reverse proxy
    services.caddy.virtualHosts."gatus.brusapa.com".extraConfig = ''
      reverse_proxy http://localhost:${toString config.services.gatus.settings.web.port}
    '';
  };
}