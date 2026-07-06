{ config, lib, ... }:

{
  imports = [
    ./disko-config.nix
    ../common/global
    ../common/users/bruno
    ../../modules/secure-boot.nix
    ../../modules/containers.nix
    ../../modules/zfs.nix
    ../../modules/server.nix
    ../../modules/tailscale-server.nix
    ./services
  ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-intel" ];
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Bootloader
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # Enable swap
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 32 * 1024; # 32 GiB
    }
  ];
  zramSwap.enable = true;

  # Networking
  networking = {
    useDHCP = true;
    useNetworkd = true;
    hostName = "saturn";
    hostId = "51a04533";
  };
  systemd.network.wait-online.enable = true;

  services.apcupsd = {
    enable = true;
    configText = ''
      UPSTYPE usb
      NISIP 0.0.0.0
      BATTERYLEVEL 15
      MINUTES 5  
    '';
  };
  networking.firewall.allowedTCPPorts = [ 3551 ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?
}
