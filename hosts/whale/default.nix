{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./disko-config.nix
    ../common/global
    ../common/users/bruno
    ../../modules/tailscale.nix
    ../../modules/secure-boot.nix
    ../../modules/hardware/intel-gpu-hw-acceleration.nix
    ../../modules/containers.nix
    ./services/postfix.nix
    ./services/caddy.nix
    ./services/homeassistant.nix
    ./services/apcupsd.nix
    ./services/frigate-container.nix
    ./services/music-assistant.nix
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
      size = 16 * 1024; # 16 GiB
    }
  ];
  zramSwap.enable = true;

  # ZFS related options
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.devNodes = "/dev/disk/by-id";
  boot.zfs.forceImportRoot = false;
  services.zfs.autoScrub = {
    enable = true;
    interval = "Mon *-*-* 22:00:00";
  };
  services.zfs.zed = {
    settings = {
      ZED_DEBUG_LOG = "/tmp/zed.debug.log";
      ZED_EMAIL_ADDR = [ "root" ];
      ZED_EMAIL_PROG = "mail";
      ZED_EMAIL_OPTS = "-s '@SUBJECT@' @ADDRESS@";

      ZED_NOTIFY_INTERVAL_SECS = 3600;
      ZED_NOTIFY_VERBOSE = true;

      ZED_USE_ENCLOSURE_LEDS = true;
      ZED_SCRUB_AFTER_RESILVER = true;
    };
  };

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
    useDHCP = true;
    useNetworkd = true;
    hostName = "whale";
    hostId = "51a04533";
  };
  systemd.network.wait-online.enable = true;

  services.tailscale.useRoutingFeatures = "server";

  # Allow VsCode SSH remote connections
  programs.nix-ld.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
