{ den, ... }:
{
  den.aspects.jupiter = {
    includes = [
      den.aspects.samba-server
    ];

    nixos.services.samba.settings = {
      ramon = {
        path = "/zleioa/users/ramon";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "valid users" = "bruno, ramon";
      };
    };
  };
}
