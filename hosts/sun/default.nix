{ inputs, lib, config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./disko-config.nix
    ../common/global
    ../common/users/bruno
    ../../modules/tailscale.nix
    ../../modules/secure-boot.nix
    ./services/jellyfin.nix
  ];

  # Bootloader.
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
  services.zfs.autoScrub.enable = true;

  fileSystems."/mnt/torrent" = {
    device = "zstorage/torrent";
    fsType = "zfs";
  };

  fileSystems."/mnt/multimedia" = {
    device = "zstorage/multimedia";
    fsType = "zfs";
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
    interfaces.enp8s0.ipv4.addresses = [ {
      address = "10.80.0.15";
      prefixLength = 24;
    } ];
    defaultGateway = "10.80.0.1";
    nameservers = [ "10.80.0.1" ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
