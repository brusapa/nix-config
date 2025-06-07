{ ... }:
{
  services.immich = {
    enable = true;
    settings = {
      server = {
        externalDomain = "https://fotos.brusapa.com";
      };
    };
    accelerationDevices = [
      "/dev/dri/renderD128"
    ];
  };

  services.caddy.virtualHosts."fotos.brusapa.com".extraConfig = ''
    reverse_proxy http://127.0.0.1:2283
  '';
}