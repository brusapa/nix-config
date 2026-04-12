{ ... }:
{
  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        "workgroup" = "WORKGROUP";
        "server string" = "jupiter";
        "netbios name" = "jupiter";
        "invalid users" = [
          "root"
        ];
        "passwd program" = "/run/wrappers/bin/passwd %u";
        security = "user";
      };
      ramon = {
        path = "/zsynology/ramon";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "valid users" = "bruno, ramon";
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
