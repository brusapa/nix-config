{ config, ... }:
let 
  version = "26.1.0";
  port = 5006;
  dataPath = "/var/lib/actual-budget";
in 
{

  systemd.tmpfiles.rules = [
    "d ${dataPath} 0775 root root -"
  ];

  # Import the needed secrets
  sops = {
    secrets = {
      "actual-budget/pocketid-client-id" = {
        sopsFile = ../secrets.yaml;
      };
      "actual-budget/pocketid-client-secret" = {
        sopsFile = ../secrets.yaml;
      };
    };
    templates."actual-budget-secrets.env" = {
      content = ''
        ACTUAL_OPENID_CLIENT_ID=${config.sops.placeholder."actual-budget/pocketid-client-id"}
        ACTUAL_OPENID_CLIENT_SECRET=${config.sops.placeholder."actual-budget/pocketid-client-secret"}
      '';
    };
  };

  virtualisation.oci-containers.containers.actual-budget = {
    image = "docker.io/actualbudget/actual-server:${version}";

    ports = [
      "${toString port}:${toString port}"
    ];

    volumes = [
      "${dataPath}:/data"
    ];

    environment = {
      ACTUAL_PORT = toString port;
      ACTUAL_LOGIN_METHOD = "openid";
      ACTUAL_ALLOWED_LOGIN_METHODS = "openid";
      ACTUAL_OPENID_DISCOVERY_URL = "https://pocketid.brusapa.com";
      ACTUAL_OPENID_SERVER_HOSTNAME = "https://actual.brusapa.com";
    };

    environmentFiles = [
      config.sops.templates."actual-budget-secrets.env".path
    ];
  };


  reverseProxy.hosts.actual.httpPort = port;
}