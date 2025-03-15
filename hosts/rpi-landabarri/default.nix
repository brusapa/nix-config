{ inputs, lib, config, pkgs, ... }:

{
  imports = [
    inputs.nixos-hardware.nixosModules.raspberry-pi-4
    ../common/global
    ../common/users/bruno
  ];

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_rpi4;
    initrd.availableKernelModules = [ "xhci_pci" "usbhid" "usb_storage" ];
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };

  hardware.enableRedistributableFirmware = true;

  networking.hostName = "rpi-landabarri";
  networking.useDHCP = lib.mkDefault true;

  networking.interfaces.enp1s0u1u1 = {
    useDHCP = false;
    ipv4.addresses = [{
      address = "192.168.0.1";
      prefixLength = 24;
    }];
  };
  networking.firewall.extraCommands = ''
    # Set up SNAT on packets going from downstream to the wider internet
    iptables -t nat -A POSTROUTING -o end0 -j MASQUERADE
  '';
  # Run a DHCP server on the downstream interface
  services.kea.dhcp4 = {
    enable = true;
    settings = {
      interfaces-config = {
        interfaces = [
          "enp1s0u1u1"
        ];
      };
      lease-database = {
        name = "/var/lib/kea/dhcp4.leases";
        persist = true;
        type = "memfile";
      };
      rebind-timer = 2000;
      renew-timer = 1000;
      subnet4 = [
        {
          id = 1;
          pools = [
            {
              pool = "192.168.0.2 - 192.168.0.255";
            }
          ];
          subnet = "192.168.0.1/24";
        }
      ];
      valid-lifetime = 4000;
      option-data = [{
        name = "routers";
        data = "192.168.0.1";
      }];
    };
  };

   # Tailscale
  services.tailscale = {
    enable = true;
    openFirewall = true;
    useRoutingFeatures = "server";
    extraSetFlags = [
      "--advertise-routes=10.80.10.0/24,192.168.0.0/24"
    ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

}
