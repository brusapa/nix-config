{
  den.aspects.samba-server.nixos =
    { config, ... }:
    {
      services.samba = {
        enable = true;
        openFirewall = true;
        settings = {
          global = {
            "workgroup" = "WORKGROUP";
            "server string" = "${config.networking.hostName}";
            "netbios name" = "${config.networking.hostName}";
            "invalid users" = [
              "root"
            ];
            "passwd program" = "/run/wrappers/bin/passwd %u";
            security = "user";

            # Optimizations for macOS y ZFS (Fruit module)
            "vfs objects" = "catia fruit streams_xattr";
            "fruit:metadata" = "stream";
            "fruit:model" = "MacSamba";
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

      # Annnounce the server to MacOS clients (Bonjour/mDNS)
      services.avahi = {
        enable = true;
        nssmdns4 = true;
        openFirewall = true;
        publish = {
          enable = true;
          userServices = true;
        };
      };
    };
}
