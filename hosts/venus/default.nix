{ inputs, lib, config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./disko-config.nix
    ../common/global
    ../common/users/bruno
    ../../modules/tailscale.nix
    ../../modules/docker.nix
  ];


  # SWAP configuration
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 32 * 1024; # 32 GiB
    }
  ];
  zramSwap.enable = true;

  # Bootloader.
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };


  # Networking
  networking = {
    hostName = "venus";
    interfaces.enX0.ipv4.addresses = [ {
      address = "10.80.0.17";
      prefixLength = 24;
    } ];
    defaultGateway = "10.80.0.1";
    nameservers = [ "10.80.0.1" ];
  };


  services.xe-guest-utilities.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
