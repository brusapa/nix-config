{ den, ...}:
{
  den.aspects.beszelHub = {
    includes = [
      den.aspects.reverse-proxy
    ];

    nixos = { config, ...}: {

      sops =  {
        secrets = {
          "beszel-hub/default-user-email" = { };
          "beszel-hub/default-user-password" = { };
          "beszel-hub/heartbeat-url" = { };
        };
        templates."beszel-hub-secrets.env".content = ''
          USER_EMAIL=${config.sops.placeholder."beszel-hub/default-user-email"}
          USER_PASSWORD=${config.sops.placeholder."beszel-hub/default-user-password"}
          HEARTBEAT_URL=${config.sops.placeholder."beszel-hub/heartbeat-url"}
        '';
      };

      services.beszel.hub = {
        enable = true;
        environment = { 
          APP_URL = "https://beszel.${config.reverseProxy.baseDomain}";
          USER_CREATION = "true";
        };
        environmentFile = config.sops.templates."beszel-hub-secrets.env".path;
      };

      reverseProxy.hosts.beszel.httpPort = config.services.beszel.hub.port;
    };
  };
}