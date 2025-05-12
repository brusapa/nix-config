{ inputs, lib, config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./disko-config.nix
    ../common/global
    ../common/users/bruno
    ../../modules/tailscale.nix
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
  services.zfs.autoScrub.enable = true;

  # Prevent suspension/hybernation
  systemd.sleep.extraConfig = ''
    AllowSuspend=no
    AllowHibernation=no
    AllowHybridSleep=no
    AllowSuspendThenHibernate=no
  '';

  # Allow boot unlock over SSH
  boot.kernelParams = [ "ip=10.80.0.15::10.80.0.1:255.255.255.0:sun::none" ];
  boot.initrd = {
    availableKernelModules = [
      "igb" # Driver for gigabit ethernet
      "i40e" # Driver for 10G ethernet
    ];
    network = {
      enable = true;
      ssh = {
        enable = true;
        # To prevent ssh clients from freaking out because a different host key is used,
        # a different port for ssh is useful (assuming the same host has also a regular sshd running)
        port = 2222; 
        # `ssh-keygen -t ed25519 -N "" -f /etc/secrets/initrd/ssh_host_ed25519_key`
        hostKeys = [ /etc/secrets/initrd/ssh_host_ed25519_key ];
        authorizedKeys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCdwwDbi4z8NgQeVGjl5dOI9MITbpFGiDOe1SE5QiTO9a548DoMTDdnerY7gkiOXSuPjTSTzVOBT3x28INhMaIQ6MqjgETDvYQlSdnFGZ1Ai1MJl02JOUoE+QiloI2U0qlVoJZrqDcYj1xL6MBTTzZhlJ0FMxFHjFd0HLDCXXMeTcXcAju5aPrrXyR+HcCKqJrYPHKH86gCGzHQVvH6Os26Oe6ykZw2iH/B8ev47Yae/0w3c09DN1uqxeTPr0/SHK6nQc6JrG0cs8V1Nt96WXtQOWqB9R1DpbdWmPY0Hh5t5WrTFdsS54JU8N02soYc6uCLPnxv4i7REzgCwwXJrC6Fxmvu5qBPGTfhi9ES6UlE+RRFxUJ8+EeG8Q2c9xXufsqvqacswc9le7QvsxiC3bQK95BXwc1p9q2ACJtay80OtgnEUMarwdWBzZzwEHtCz9gMnsPh+wwRowZy/cPurvHCtk76qMPhILe4XDs3njw/Lmtpl7zjf/3hILLQlNyELLjXmv9wncGmQs+XZ1Z1htmClQRpzpy83Q1dfuJH2cPOG3OZcouf2tIPUZI+lb/CTtPXndDH1sYs6Sqt1WVk17uwLFq1JIWKhUOYO/z1z/0e6+A0rmeZlMIn2AGW7v96RfRhWP6WSrwdjc5z1ZQYTOuhlcfb2dKMbfd8nxwZ0pRNyw== gpgBruno" ];
      };
    };
  };

  # Networking
  networking = {
    hostName = "sun";
    interfaces.enX0.ipv4.addresses = [ {
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
