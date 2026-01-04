{ config,  ... }:
{
  sops.secrets.radicale-htpasswd = {
    sopsFile = ../secrets/radicale_users.sops;
    format = "binary";
    owner = "radicale";
    group = "radicale";
    mode = "0400";
  };

  services.radicale = {
    enable = true;
    settings = {
      server.hosts = [ "0.0.0.0:5232" "[::]:5232" ];
      auth = {
        type = "htpasswd";
        htpasswd_filename = config.sops.secrets.radicale-htpasswd.path;
        htpasswd_encryption = "bcrypt";
      };
    };
  };

  reverseProxy.hosts.radicale.httpPort = 5232;
}