{ den, ... }:
{
  den.hosts.x86_64-linux.pluto = {
    role = "server";
    users.bruno = {};
    swapSizeGiB = 16;
  };

  den.aspects.pluto = {
    includes = [
      # Role
      den.aspects.server

      # Other features
      den.aspects.zfs
      den.aspects.tailscale-server

      # Hardware
      den.aspects.intel-cpu
    ];

    nixos = {
      # ZFS related options
      zfs.extraPools = [ "zbackup" ];
      boot.zfs.requestEncryptionCredentials = false;
      # Unique host identifier used for ZFS
      networking.hostId = "d2a8542a";

      sops.defaultSopsFile = ./secrets.yaml;

      system.stateVersion = "24.05";
    };
  };
}