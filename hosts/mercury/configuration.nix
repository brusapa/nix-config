{ inputs, lib, config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix # Include the results of the hardware scan.
    inputs.nixos-hardware.nixosModules.framework-13-inch-7040-amd
    ../../modules/plymouth.nix
    ../../modules/hardware/yubikey.nix
    ../common.nix
    ../../home/users.nix
    ../../home/bruno/network-shares.nix
    ../../home/gurenda/network-shares.nix
    ../../modules/tailscale.nix
    ../../modules/kde.nix
    ../../modules/flatpak.nix
    ../../modules/virtualisation.nix
    ../../modules/office.nix
    ../../modules/multimedia.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "mercury"; # Define your hostname.

  # Wireless
  networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Bluetooth
  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.avahi = {
    enable = true;
    nssmdns = true;
    openFirewall = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

}
