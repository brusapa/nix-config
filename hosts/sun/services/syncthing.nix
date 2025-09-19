{ ... }:
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
    };
  };

  services.caddy.virtualHosts."syncthing.brusapa.com".extraConfig = ''
    reverse_proxy http://localhost:8384
  '';
}