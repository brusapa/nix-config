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

  myservices.reverseProxy.hosts.ntfy.httpPort = 34567;

}