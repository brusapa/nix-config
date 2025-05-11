{ pkgs, ... }:

{
  # Create a group for the jellyfin service
  users.groups.multimedia.gid = 3001;

  # Create a user for the jellyfin service
  users.users.multimedia = {
    uid = 3001;
    group = "multimedia";
    isSystemUser = true;
    createHome = false;
  };

  # Mount the NFS share for multimedia
  fileSystems."/mnt/multimedia" = {
    device = "sun.brusapa.com:/mnt/Temporal/multimedia";
    fsType = "nfs";
  };
  fileSystems."/mnt/plex" = {
    device = "10.80.0.5:/volume2/plex";
    fsType = "nfs";
  };
  # optional, but ensures rpc-statsd is running for on demand mounting
  boot.supportedFilesystems = [ "nfs" ];

}
