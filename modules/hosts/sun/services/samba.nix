{ den, ... }:
{
  den.aspects.sun = {
    includes = [
      den.aspects.samba-server
    ];

    nixos.services.samba.settings = {
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
        "read only" = "no";
        "guest ok" = "no";
        "valid users" = "bruno";
      };
      whale-frigate = {
        path = "/mnt/satassd/whale-frigate-sync";
        browseable = "yes";
        "read only" = "yes";
        "guest ok" = "no";
        "valid users" = "bruno";
      };
    };
  };
}
