{ den, ... }:
{
  den.hosts.x86_64-linux.uranus = {
    role = "server";
    users.bruno = { };
    swapSizeGiB = 16;
  };

  den.aspects.uranus = {
    includes = [
      # Role
      den.aspects.server

      # Other features
      den.aspects.secure-boot
      den.aspects.zfs
      den.aspects.mail-server
      den.aspects.tailscale-server
      den.aspects.beszelAgent

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
