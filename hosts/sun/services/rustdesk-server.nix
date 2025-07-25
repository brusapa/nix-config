{ ... }:
{
  services.rustdesk-server = {
    enable = true;
    signal.relayHosts = [ "sun.brusapa.com" ];
    openFirewall = true;
  };
}