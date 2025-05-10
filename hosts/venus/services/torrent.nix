{ ... }:

{
  # Create a group for the torrent service
  users.groups.torrent.gid = 3000;

  # Create a user for the torrent service
  users.users.torrent = {
    uid = 3000;
    isSystemUser = true;
    createHome = false;
  };

  # Mount the NFS share for torrent
  fileSystems."/mnt/torrent" = {
    device = "sun.brusapa.com:/torrent";
    fsType = "nfs";
  };
  # optional, but ensures rpc-statsd is running for on demand mounting
  boot.supportedFilesystems = [ "nfs" ];
}