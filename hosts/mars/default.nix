{ inputs, pkgs, config, ... }:

{
  imports = [
    ./hardware-configuration.nix # Include the results of the hardware scan.
    inputs.nixos-hardware.nixosModules.common-hidpi
    inputs.nixos-hardware.nixosModules.common-cpu-amd
    inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
    # inputs.nixos-hardware.nixosModules.common-cpu-amd-zenpower
    inputs.nixos-hardware.nixosModules.common-pc
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    ../../modules/hardware/amd-gpu.nix
    #./disko-config.nix
    ../../modules/secure-boot.nix
    ../../modules/hardware/logitech.nix
    ../../modules/hardware/yubikey.nix
    ../../modules/hardware/keychron.nix
    ../../modules/hardware/printers/brother-printer.nix
    ../common/global
    ../common/users/bruno
    ../common/users/bruno/nas-network-shares.nix
    ../common/users/gurenda
    ../common/users/gurenda/nas-network-shares.nix
    ../../modules/tailscale.nix
    ../../modules/kde.nix
    ../../modules/containers.nix
    ../../modules/libvirtd.nix
    ../../modules/gaming.nix
    ../../modules/sunshine.nix
    ../../modules/quiet-boot.nix
    ../../modules/localsend.nix
    ../../modules/flatpak.nix
  ];

  # Create a swap file for hibernation.
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 64 * 1024; # 64 GiB
    }
  ];
  zramSwap.enable = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Add EC sensors for asus motherboards
  boot.extraModulePackages = with config.boot.kernelPackages; [ asus-ec-sensors ];
  environment.systemPackages = with pkgs; [
    lm_sensors
    furmark
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking = {
    hostName = "mars";
    hostId = "c66a2250";
  };

  # Enable Wake On Lan
  networking.interfaces.eno1.wakeOnLan.enable = true;

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
