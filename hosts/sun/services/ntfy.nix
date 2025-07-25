{ ... }:
{
  services.ntfy-sh = {
    enable = true;
    settings = {
      base-url = "https://ntfy.brusapa.com";
      listen-http = ":34567";
      behind-proxy = true;
    };
  };

  # Reverse proxy
  services.caddy.virtualHosts."ntfy.brusapa.com".extraConfig = ''
    reverse_proxy http://localhost:34567
  '';
}