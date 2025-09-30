{ config, ... }:
{
  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    settings = {
      gui = {
        addressess = "127.0.0.1:8384";
        useTLS = false;
        insecureSkipHostcheck = true;
      };
      options = {
        urAccepted = -1;
        localAnnounceEnabled = false;
      };
      devices = {
        sonabia-syncthing = {
          addressess = [
            "tcp://sonabia.brusapa.com:22000"
          ];
          id = "5WN3QDC-6M2RMOF-OIQFK2D-LW2PDND-YXKVHTV-N6TT4PH-KGIOA63-KXMKEAZ";
        };
      };
      folders = {
        Frigate = {
          enable = true;
          id = "vgawf-ewsaf";
          type = "receiveonly";
          path = "/mnt/satassd/sonabiafrigate";
          devices = [
            "sonabia-syncthing"
          ];
        };
      };
    };
  };

  services.caddy.virtualHosts."syncthing.brusapa.com".extraConfig = ''
    reverse_proxy http://${toString config.services.syncthing.guiAddress}
  '';
}