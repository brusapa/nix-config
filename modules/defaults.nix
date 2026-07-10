{ inputs, lib, den, ... }:
{
  imports = [ inputs.den.flakeModule ];

  den.default = {
    includes = [
      den.batteries.hostname
      
      den.aspects.swap
      den.aspects.locale
      den.aspects.gnupg-agent
      den.aspects.openssh-server
      den.aspects.sops
    ];

    nixos = { lib, ... }:
    {
      # Default hardware options
      boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
      boot.initrd.kernelModules = [ "dm-snapshot" ];
      hardware.enableRedistributableFirmware = true;

      # Default group for users
      users.groups.users.gid = 100;

      nix = {
        # Garbage collection
        gc = {
          automatic = true;
          dates = "weekly";
          options = "--delete-older-than +5";
        };
        settings = {
          auto-optimise-store = true;
          experimental-features = [ "nix-command" "flakes" ];
        };
      };
      nixpkgs.config.allowUnfree = true;
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
      };

      # Run unpatched dynamic binaries on NixOS.
      programs.nix-ld.enable = true;

      # Network related options
      networking = {
        domain = "brusapa.com";
        firewall = {
          enable = true;
          allowPing = true;
        };
      };

      system.stateVersion =  lib.mkDefault "26.05";
    };

    homeManager =  {lib, ...}: {
      home.stateVersion = lib.mkDefault "26.05";
    };
  };

  # enable hm by default
  den.schema.user.classes = lib.mkDefault [ "homeManager" ];
}