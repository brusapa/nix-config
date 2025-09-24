{ inputs, lib, config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./disko-config.nix
    ../common/global
    ../common/users/bruno
    ../common/users/gurenda
    ../../modules/tailscale.nix
    ../../modules/secure-boot.nix
    ../../modules/intel-gpu-hw-acceleration.nix
    ./services/samba.nix
    ./services/postfix.nix
    ./services/caddy.nix
    ./services/nixarr.nix
    ./services/vaultwarden.nix
    ./services/karakeep.nix
    ./services/homeassistant.nix
    ./services/ollama.nix
    ./services/webdav.nix
    ./services/backups.nix
    ./services/immich.nix
    ./services/paperless.nix
    ./services/apcupsd.nix
    ./services/homebox.nix
    #./services/monitoring.nix
    ./services/aitas-backup.nix
    ./services/pangolin-client.nix
    ./services/gatus.nix
    ./services/ntfy.nix
    ./services/rustdesk-server.nix
    ./services/frigate-container.nix
    ./services/syncthing.nix
  ];

  environment.systemPackages = [
    pkgs.restic
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
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.devNodes = "/dev/disk/by-id";
  boot.zfs.forceImportRoot = false;
  boot.zfs.extraPools = [ "zstorage" ];
  services.zfs.autoScrub = {
    enable = true;
    interval = "weekly";
  };
  services.zfs.zed.settings = {
    ZED_DEBUG_LOG = "/tmp/zed.debug.log";
    ZED_EMAIL_ADDR = [ "root" ];
    ZED_EMAIL_PROG = "${pkgs.msmtp}/bin/msmtp";
    ZED_EMAIL_OPTS = "@ADDRESS@";

    ZED_NOTIFY_INTERVAL_SECS = 3600;
    ZED_NOTIFY_VERBOSE = true;

    ZED_USE_ENCLOSURE_LEDS = true;
    ZED_SCRUB_AFTER_RESILVER = true;
  };

  # SMART checks
  services.smartd = {
    enable = true;
    notifications = {
      mail.enable = true;
    };
  };

  # Backup userdata
  backup.job.userdata.paths = [
    "/zstorage/users"
  ];

  # Mount internal backup and sata ssd disks
  environment.etc."crypttab".text = ''
    cryptbackup /dev/disk/by-id/nvme-CT4000P3SSD8_2336E8744EB7-part1 /root/internalBackup.key
    cryptsatassd /dev/disk/by-id/ata-SanDisk_SDSSDH3_2T00_23212E800066 /root/internalBackup.key
  '';
  fileSystems."/mnt/internalBackup".device = "/dev/mapper/cryptbackup";
  fileSystems."/mnt/satassd".device = "/dev/mapper/cryptsatassd";

  # Power management
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "powersave";
    powertop.enable = true;
  };

  # Prevent suspension/hybernation
  systemd.sleep.extraConfig = ''
    AllowSuspend=no
    AllowHibernation=no
    AllowHybridSleep=no
    AllowSuspendThenHibernate=no
  '';

  # Networking
  networking = {
    hostName = "sun";
    hostId = "696795a0";
  };

  services.tailscale.useRoutingFeatures = "server";

  # Allow VsCode SSH remote connections
  programs.nix-ld.enable = true;

  # Nvidia
  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.open = true;
  # CUDA cache
  nix.settings = {
    substituters = [
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
