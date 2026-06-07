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

        # Optimizaciones para macOS y ZFS (Módulo Fruit)
        "vfs objects" = "catia fruit streams_xattr";
        "fruit:metadata" = "stream"; # Guarda los atributos de Mac como xattrs de ZFS
        "fruit:model" = "MacSamba";  # Muestra un icono de Mac en el Finder
        "fruit:posix_rename" = "yes";
        "fruit:veto_appledouble" = "no";
        "fruit:nfs_aces" = "no";
        "fruit:wipe_intentionally_left_blank_rfork" = "yes";
        "fruit:delete_empty_adfiles" = "yes";
      };
      ramon = {
        path = "/zleioa/users/ramon";
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

  # Anuncia el servidor a clientes macOS (Bonjour/mDNS)
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
    publish = {
      enable = true;
      userServices = true;
    };
  };

  networking.firewall.allowPing = true;
}
