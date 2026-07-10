{ den, ... }:
{
  den.hosts.x86_64-linux.jupiter = {
    role = "server";
    users = {
      bruno = {};
      ramon = {};
    };
    swapSizeGiB = 32;
  };

  den.aspects.jupiter = {
    includes = [
      # Role
      den.aspects.server

      # Other features
      den.aspects.acme
      den.aspects.zfs
      den.aspects.containers
      den.aspects.reverse-proxy

      # Hardware
      den.aspects.amd-cpu
      den.aspects.apcupsd
    ];

    nixos = 
      { pkgs, ... }:
      {
        # ZFS related options
        zfs = {
          enable = true;
          extraPools = [ "znvme" "zleioa" ];
        };
        # Unique host identifier used for ZFS
        networking.hostId = "e5501645";

        sops.defaultSopsFile = ./secrets.yaml;

        reverseProxy.baseDomain = "leioa.brusapa.com";

        environment.systemPackages = [
          pkgs.restic
          pkgs.lzop
          pkgs.mbuffer
        ];

        # User for ZFS remote backup
        users.groups.zfspuller = {};
        users.users.zfspuller = {
          group = "zfspuller";
          extraGroups = [
            "ssh-login"
          ];
          isSystemUser = true;
          shell = pkgs.bashInteractive;
          openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINuHKh5dLEYV+tREc4y9+S+YwgwCZJnJv366eyNTY/B4 sun-zfs-puller"
          ];
        };

        system.stateVersion = "24.05";
      };
  };
}