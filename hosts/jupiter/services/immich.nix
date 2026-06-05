{ config, pkgs, ... }:
{
  # Import the needed secrets
  sops = {
    secrets = {
      "immich/pocketid-client-id" = {
        sopsFile = ../secrets.yaml;
      };
      "immich/pocketid-client-secret" = {
        sopsFile = ../secrets.yaml;
      };
    };
  };

  services.immich = {
    enable = true;
    mediaLocation = "/zleioa/immich";
    settings = {
      server = {
        externalDomain = "https://fotos.leioa.brusapa.com";
      };
      storageTemplate = {
        enabled = true;
        hashVerificationEnabled = true;
        template = "{{y}}/{{#if album}}{{album}}{{else}}Other{{/if}}/{{filename}}";
      };
      notifications = {
        smtp = {
          enabled = true;
          from = "fotos@leioa.brusapa.com";
          transport = {
            host = "127.0.0.1";
            port = 25;
          };
        };
      };
      oauth = {
        enabled = true;
        buttonText = "Login with PocketID";
        clientId._secret = config.sops.secrets."immich/pocketid-client-id".path;
        clientSecret._secret = config.sops.secrets."immich/pocketid-client-secret".path;
        issuerUrl = "https://pocketid.leioa.brusapa.com";
      };
    };
    accelerationDevices = [
      "/dev/dri/renderD128"
    ];
  };

  users.users.${config.services.immich.user}.extraGroups = [ "ramon" ];

  reverseProxy.hosts.fotos = {
    ip = "localhost";
    httpPort = config.services.immich.port;
  };
}
