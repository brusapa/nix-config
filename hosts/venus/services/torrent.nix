{ pkgs, ... }:

{
  # Create a group for the torrent service
  users.groups.torrent.gid = 3000;

  # Create a user for the torrent service
  users.users.torrent = {
    uid = 3000;
    group = "torrent";
    isSystemUser = true;
    createHome = false;
  };

  # Mount the NFS share for torrent
  fileSystems."/mnt/torrent" = {
    device = "sun.brusapa.com:/mnt/Temporal/torrent";
    fsType = "nfs";
  };
  # optional, but ensures rpc-statsd is running for on demand mounting
  boot.supportedFilesystems = [ "nfs" ];


  services.transmission = {
    enable = true;
    package = pkgs.transmission_4;
    user = "torrent";
    group = "torrent";
    openFirewall = true;
    openRPCPort = true;
    settings = {
      download-dir = "/mnt/torrent";
      rpc-bind-address = "0.0.0.0";
      rpc-host-whitelist-enabled = false;
      rpc-whitelist-enabled = false;
    };
  };
}
