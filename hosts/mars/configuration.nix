{ inputs, lib, config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix # Include the results of the hardware scan.
    inputs.nixos-hardware.nixosModules.common-hidpi
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-pc
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    inputs.nixos-hardware.nixosModules.common-gpu-amd
    ../../modules/plymouth.nix
    ../../modules/hardware/logitech.nix
    ../../modules/hardware/yubikey.nix
    ../common.nix
    ../../home/users.nix
    ../../home/bruno/network-shares.nix
    ../../home/gurenda/network-shares.nix
    ../../modules/tailscale.nix
    ../../modules/kde.nix
    ../../modules/flatpak.nix
    ../../modules/virtualisation.nix
    ../../modules/gaming.nix
    ../../modules/office.nix
    ../../modules/multimedia.nix
  ];

  environment.systemPackages = with pkgs; [
    lm_sensors
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Detect fans
  boot.extraModulePackages = with config.boot.kernelPackages; [ it87 ];
  boot.kernelModules = [ "it87" ];
  boot.extraModprobeConfig = ''
    options it87 force_id=0x8628
  '';

  programs.coolercontrol.enable = true;

  networking.hostName = "mars"; # Define your hostname.

  # Enable Wake On Lan
  networking.interfaces.enp7s0.wakeOnLan.enable = true;

  # Wireless
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

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
