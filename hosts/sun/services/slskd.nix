{ config, ... }:
{
  # Import the needed secrets
  sops = {
    secrets = {
      "slskd/username" = {
        sopsFile = ../secrets.yaml;
      };
      "slskd/password" = {
        sopsFile = ../secrets.yaml;
      };
      "slskd/slsk-username" = {
        sopsFile = ../secrets.yaml;
      };
      "slskd/slsk-password" = {
        sopsFile = ../secrets.yaml;
      };
    };
    templates."slskd-secrets.env" = {
      content = ''
        SLSKD_USERNAME=${config.sops.placeholder."slskd/username"}
        SLSKD_PASSWORD=${config.sops.placeholder."slskd/password"}
        SLSKD_SLSK_USERNAME=${config.sops.placeholder."slskd/slsk-username"}
        SLSKD_SLSK_PASSWORD=${config.sops.placeholder."slskd/slsk-password"}
      '';
    };
  };

  services.slskd = {
    enable = true;
    openFirewall = true;
    environmentFile = config.sops.templates."slskd-secrets.env".path;
    domain = null;
    settings = {
      shares = {
        directories = [ 
          "/zstorage/media/library/music" 
        ];
      };
      web = {
        authentication = {
          api_keys = {
            my_api_key = {
              key = "";
              cidr = "0.0.0.0/0,::/0";
            };
          };
        };
      };
    };
  };

  services.caddy.virtualHosts."slskd.brusapa.com".extraConfig = ''
    reverse_proxy http://localhost:${toString config.services.slskd.settings.web.port}
  '';
}
