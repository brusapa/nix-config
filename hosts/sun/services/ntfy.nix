{ config, ... }:
{
  # Import the needed secrets
  sops = {
    secrets = {
      "ntfy/bruno-password" = {
        sopsFile = ../secrets.yaml;
      };
      "ntfy/sun-password" = {
        sopsFile = ../secrets.yaml;
      };
      "ntfy/sun-zfs-token" = {
        sopsFile = ../secrets.yaml;
      };
    };
    templates."ntfy-secrets.env" = {
      content = ''
        NTFY_AUTH_USERS="bruno:${config.sops.placeholder."ntfy/bruno-password"}:admin,sun:${config.sops.placeholder."ntfy/sun-password"}:user"
        NTFY_AUTH_TOKENS="sun:${config.sops.placeholder."ntfy/sun-zfs-token"}:sun-zfs"
      '';
    };
  };

  services.ntfy-sh = {
    enable = true;
    settings = {
      base-url = "https://ntfy.brusapa.com";
      listen-http = ":34567";
      behind-proxy = true;
      auth-default-access = "deny-all";
      enable-login = true;
      auth-access = [
        "sun:sun:rw"
      ];
    };
    environmentFile = config.sops.templates."ntfy-secrets.env".path;
  };

  reverseProxy.hosts.ntfy.httpPort = 34567;

}