{
  den.aspects.influxdb.nixos = { config, ... }: {

    # Import the needed secrets
    sops = {
      secrets = {
        "influxdb/admin-password" = {
          owner = "influxdb2";
        };
        "influxdb/admin-token" = {
          owner = "influxdb2";
        };
      };
    };

    services.influxdb2 = {
      enable = true;
      provision = {
        enable = true;
        initialSetup = {
          organization = "main";
          bucket = "main";
          passwordFile = config.sops.secrets."influxdb/admin-password".path;
          tokenFile = config.sops.secrets."influxdb/admin-token".path;
        };
      };
    };

    reverseProxy.hosts.influxdb.httpPort = 8086;
  };
}