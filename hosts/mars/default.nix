{ inputs, lib, config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix # Include the results of the hardware scan.
    inputs.nixos-hardware.nixosModules.common-hidpi
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-pc
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    inputs.nixos-hardware.nixosModules.common-gpu-amd
    #./disko-config.nix
    ../../modules/secure-boot.nix
    ../../modules/plymouth.nix
    ../../modules/hardware/logitech.nix
    ../../modules/hardware/yubikey.nix
    ../../modules/hardware/keychron.nix
    ../../modules/hardware/printers/brother-printer.nix
    ../../modules/hardware/scarlett.nix
    ../common/global
    ../common/users/bruno
    ../common/users/bruno/nas-network-shares.nix
    ../common/users/gurenda
    ../common/users/gurenda/nas-network-shares.nix
    ../../modules/tailscale.nix
    ../../modules/kde.nix
    ../../modules/docker.nix
    ../../modules/libvirtd.nix
    ../../modules/gaming.nix
    ../../modules/sunshine.nix
    ../../modules/office.nix
    ../../modules/multimedia.nix
    ../../modules/development.nix
    ../../modules/quiet-boot.nix
  ];

  # Create a swap file for hibernation.
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 64 * 1024; # 64 GiB
    }
  ];
  zramSwap.enable = true;

  environment.systemPackages = with pkgs; [
    lm_sensors
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel available
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Detect fans on Gigabyte Z690 motherboard
  boot.kernelParams = [ "acpi_enforce_resources=lax" ];
  boot.kernelModules = [ "coretemp" "it87" ];
  boot.extraModprobeConfig = ''
    options it87 force_id=0x8628
  '';

  # Cooler control
  programs.coolercontrol.enable = true;
  environment.etc.coolercontrol-config-file = {
    target = "coolercontrol/config.toml";
    mode = "0644";
    source = ./coolercontrol-config.toml;
  };

  networking.hostName = "mars"; # Define your hostname.

  # Fix immediate wake up after suspend
  services.udev.extraRules = ''
    ACTION=="add" SUBSYSTEM=="pci" ATTR{vendor}=="0x8086" ATTR{device}=="0x7ae0" ATTR{power/wakeup}="disabled"
  '';

  # Enable Wake On Lan
  networking.interfaces.enp7s0.wakeOnLan.enable = true;

  # Bluetooth
  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

}
