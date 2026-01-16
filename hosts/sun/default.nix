{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./disko-config.nix
    ../common/global
    ../common/users/bruno
    ../common/users/gurenda
    ../../modules/tailscale.nix
    ../../modules/secure-boot.nix
    ../../modules/hardware/intel-gpu-hw-acceleration.nix
    ../../modules/containers.nix
    ../../modules/zfs.nix
    ../../modules/server.nix
    ./services
    ./services/samba.nix
    ./services/postfix.nix
    ./services/caddy.nix
    ./services/nixarr.nix
    ./services/servarr
    ./services/vaultwarden.nix
    ./services/karakeep.nix
    ./services/homeassistant.nix
    ./services/webdav.nix
    ./services/backups.nix
    ./services/immich.nix
    ./services/paperless.nix
    ./services/apcupsd.nix
    ./services/homebox.nix
    ./services/monitoring.nix
    ./services/aitas-backup.nix
    ./services/pangolin-client.nix
    ./services/gatus.nix
    ./services/ntfy.nix
    ./services/rustdesk-server.nix
    ./services/frigate-container.nix
    ./services/music-assistant.nix
    ./services/unpackerr.nix
    ./services/qbittorrent.nix
    ./services/dispatcharr.nix
    ./services/backups-offsite.nix
    ./services/radicale.nix
    ./services/whale-frigate-sync.nix
  ];

  # Import the needed secrets
  sops.secrets = {
    "ntfy/sun-zfs-token" = {
      sopsFile = ./secrets.yaml;
    };
  };

  environment.systemPackages = [
    pkgs.restic
    pkgs.lzop
    pkgs.mbuffer
  ];

  # Bootloader
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # Enable swap
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 64 * 1024; # 32 GiB
    }
  ];
  zramSwap.enable = true;

  # ZFS related options
  zfs = {
    enable = true;
    ntfy = {
      enable = true;
      topic = "sun";
      tokenFile = config.sops.secrets."ntfy/sun-zfs-token".path;
    };
  };
  boot.zfs.extraPools = [ "zstorage" ];

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

  # Backup userdata
  backup-offsite-landabarri.job.userdata.paths = [
    "/zstorage/users"
  ];

  # Mount internal backup and sata ssd disks
  environment.etc."crypttab".text = ''
    cryptbackup /dev/disk/by-id/nvme-CT4000P3SSD8_2336E8744EB7-part1 /root/internalBackup.key
    cryptsatassd /dev/disk/by-id/ata-SanDisk_SDSSDH3_2T00_23212E800066 /root/satassd.key
  '';
  fileSystems."/mnt/internalBackup".device = "/dev/mapper/cryptbackup";
  fileSystems."/mnt/satassd".device = "/dev/mapper/cryptsatassd";

  # Networking
  networking = {
    useDHCP = true;
    useNetworkd = true;
    hostName = "sun";
    domain = "brusapa.com";
    hostId = "696795a0";
  };
  systemd.network.wait-online.enable = true;

  systemd.network.links = {
    "10-lan1s1g" = {
      matchConfig.MACAddress = "9c:6b:00:45:80:66";
      linkConfig.Name = "lan1s1g";
    };
    "10-lan2s1g" = {
      matchConfig.MACAddress = "9c:6b:00:45:80:67";
      linkConfig.Name = "lan2s1g";
    };
    "10-lan3s10g" = {
      matchConfig.MACAddress = "9c:6b:00:45:80:68";
      linkConfig.Name = "lan3s10g";
    };
    "10-lan4s10g" = {
      matchConfig.MACAddress = "9c:6b:00:45:80:69";
      linkConfig.Name = "lan4s10g";
    };
  };

  services.tailscale.useRoutingFeatures = "server";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
