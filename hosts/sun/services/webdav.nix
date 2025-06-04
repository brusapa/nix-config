{ config, ... }:
{
  # Import the needed secrets
  sops = {
    secrets = {
      "webdav/obsidian-personal-password" = {
        sopsFile = ../secrets.yaml;
      };
      "webdav/obsidian-work-password" = {
        sopsFile = ../secrets.yaml;
      };
    };
    templates."webdav-secrets.env" = {
      content = ''
        OBSIDIAN_PERSONAL_PASSWORD=${config.sops.placeholder."webdav/obsidian-personal-password"}
        OBSIDIAN_WORK_PASSWORD=${config.sops.placeholder."webdav/obsidian-work-password"}
      '';
    };
  };

  services.webdav = {
    enable = true;
    settings = {
      address = "127.0.0.1";
      port = 48989;
      behindProxy = true;
      path = "/var/lib/webdav";
      users = [
        {
          username = "obsidian-personal";
          password = "{env}OBSIDIAN_PERSONAL_PASSWORD";
          permissions = "CRUD";
          directory = "/var/lib/webdav/obsidian-personal";
        }
        {
          username = "obsidian-work";
          password = "{env}OBSIDIAN_WORK_PASSWORD";
          permissions = "CRUD";
          directory = "/var/lib/webdav/obsidian-work";
        }
      ];
    };
    environmentFile = config.sops.templates."webdav-secrets.env".path;
  };

  services.caddy.virtualHosts."webdav.brusapa.com".extraConfig = ''
    reverse_proxy http://127.0.0.1:48989
  '';
}
