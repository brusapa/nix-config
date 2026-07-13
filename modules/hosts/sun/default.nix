{ den, ... }:
{
  den.hosts.x86_64-linux.sun = {
    role = "server";
    users = {
      bruno = {};
      gurenda = {};
    };
    swapSizeGiB = 32;
  };

  den.aspects.sun = {
    includes = [
      # Role
      den.aspects.server

      # Other features
      den.aspects.zfs
      den.aspects.containers
      den.aspects.reverse-proxy
      den.aspects.mail-server
      den.aspects.wallaos
      den.aspects.pocket-id
      den.aspects.immich
      den.aspects.acme
      den.aspects.dawarich
      den.aspects.karakeep
      den.aspects.mealie
      den.aspects.pangolin-client

      # Hardware
      den.aspects.intel-cpu
      den.aspects.intel-gpu-hw-acceleration
      den.aspects.apcupsd
    ];

    nixos = { pkgs, ... }: {

      # Mount internal backup and sata ssd disks
      environment.etc."crypttab".text = ''
        cryptbackup /dev/disk/by-id/nvme-CT4000P3SSD8_2336E8744EB7-part1 /root/internalBackup.key
        cryptsatassd /dev/disk/by-id/ata-SanDisk_SDSSDH3_2T00_23212E800066 /root/satassd.key
      '';
      fileSystems."/mnt/internalBackup" = {
        device = "/dev/mapper/cryptbackup";
        fsType = "ext4";
      };
      fileSystems."/mnt/satassd" = {
        device = "/dev/mapper/cryptsatassd";
        fsType = "ext4";
      };

      # ZFS related options
      zfs = {
        extraPools = [ "zstorage" ];
        autoSnapshots = [
          {
            pool = "zstorage";
            datasets = [
              "users"
              "paperless"
              "photos"
              "internal-backups"
            ];
          }
        ];
        pullerAuthorizedSshKeys = [
          ../pluto/zfspuller-key.pub
        ];
      };
      # Unique host identifier used for ZFS
      networking.hostId = "696795a0";

      sops.defaultSopsFile = ./secrets.yaml;

      users.groups.media = {
        gid = 169;
        members = [ "bruno" ];
      };

      systemd.tmpfiles.rules = [
        "d /zstorage/media 2775 root media - -"
      ];

      # Immich configuration
      services.immich.mediaLocation = "/zstorage/photos";

      reverseProxy = {
        baseDomain = "brusapa.com";
        hosts = {
          router = {
            ip = "10.80.0.1";
            httpsPort = 443;
          };
          "router.trastero" = {
            ip = "10.80.9.1";
            httpsPort = 443;
          };
        };
      };

      system.stateVersion = "24.05";
    };
  };
}