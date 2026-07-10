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
        enable = true;
        extraPools = [ "zstorage" ];
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
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOOaO0c4HI5UOaCYPBH4MGgvWWN3kAZf7Q/owsQsGPcT syncoid-pluto"
        ];
      };

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