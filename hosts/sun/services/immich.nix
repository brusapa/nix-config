{ ... }:
{
  services.immich = {
    enable = true;
    mediaLocation = "/zstorage/photos";
    settings = {
      server = {
        externalDomain = "https://fotos.brusapa.com";
      };
      notifications = {
        smtp = {
          enabled = true;
          from = "fotos@brusapa.com";
          transport = {
            host = "127.0.0.1";
            port = 25;
          };
        };
      };
    };
    accelerationDevices = [
      "/dev/dri/renderD128"
    ];
  };

  services.caddy.virtualHosts."fotos.brusapa.com".extraConfig = ''
    reverse_proxy http://localhost:2283
  '';
}
