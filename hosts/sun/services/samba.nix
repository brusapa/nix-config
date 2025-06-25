{ ... }:
{
  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        "workgroup" = "WORKGROUP";
        "server string" = "sun";
        "netbios name" = "sun";
        "invalid users" = [
          "root"
        ];
        "passwd program" = "/run/wrappers/bin/passwd %u";
        security = "user";
      };
      bruno = {
        path = "/zstorage/users/bruno";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "valid users" = "bruno";
      };
      gurenda = {
        path = "/zstorage/users/gurenda";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "valid users" = "gurenda";
      };
      casa = {
        path = "/zstorage/users/casa";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "valid users" = "bruno, gurenda";
      };
      media = {
        path = "/zstorage/media";
        browseable = "yes";
        "read only" = "yes";
        "guest ok" = "no";
      };
    };
  };

  # Used to advertise the shares to windows hosts
  services.samba-wsdd = {
    enable = false;
    openFirewall = true;
  };

  networking.firewall.allowPing = true;
}
