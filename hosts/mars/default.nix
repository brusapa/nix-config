{ inputs, pkgs, config, lib, ... }:

{
  imports = [
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
  ];

  # Hardware configuration section
  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" ];
  boot.kernelModules = [ "kvm-amd" ];
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # TODO: Replace the following with the disko config
  fileSystems."/" =
  { device = "/dev/disk/by-uuid/7ab38f8e-d1e3-48be-9e34-89ba94380a2d";
    fsType = "ext4";
  };
  boot.initrd.luks.devices."cryptroot".device = "/dev/disk/by-uuid/cdba122e-11e0-4d6a-8bd6-3c7a0bd47b3a";
  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/AB24-BEBF";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

  # Create a swap file for hibernation.
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 64 * 1024; # 64 GiB
    }
  ];
  zramSwap.enable = true;

  # Add EC sensors for asus motherboards
  boot.extraModulePackages = with config.boot.kernelPackages; [ asus-ec-sensors ];
  environment.systemPackages = with pkgs; [
    lm_sensors
    furmark
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # NETWORK
  networking = {
    hostName = "mars";
    hostId = "c66a2250";
  };

  # Enable Wake On Lan
  networking.interfaces.eno1.wakeOnLan.enable = true;

  # Bluetooth
  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot

  # GPU

  # Control GPU fans and undervolt
  hardware.amdgpu.overdrive.enable = true;
  services.lact = {
    enable = true;
    settings = {
      version = 5;
      daemon = {
        log_level = "info";
        admin_group = "wheel";
        disable_clocks_cleanup = false;
      };
      apply_settings_timer = 5;
      gpus = {
        "1002:747E-1DA2:D475-0000:03:00.0" = {
          fan_control_enabled = false;
          pmfw_options = {
            zero_rpm = true;
          };
          performance_level = "auto";
          voltage_offset = -75;
        };
      };
      current_profile = null;
      auto_switch_profiles = false;
    };
  };


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

}
