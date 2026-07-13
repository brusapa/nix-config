{
  inputs,
  lib,
  den,
  ...
}:
{
  imports = [
    (inputs.flake-file.flakeModules.dendritic or { })
    (inputs.den.flakeModules.dendritic or { })
  ];

  # Common flake modules
  flake-file.inputs = {
    nixpkgs.url = "nixpkgs/nixos-26.05";
    flake-file.url = "github:denful/flake-file";
    den.url = "github:denful/den";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  den.default = {
    includes = [
      den.batteries.hostname

      den.aspects.swap
      den.aspects.locale
      den.aspects.gnupg-agent
      den.aspects.openssh-server
      den.aspects.sops
    ];

    nixos =
      { lib, ... }:
      {
        # Default hardware options
        boot.initrd.availableKernelModules = [
          "xhci_pci"
          "ahci"
          "nvme"
          "usbhid"
          "usb_storage"
          "sd_mod"
        ];
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
            experimental-features = [
              "nix-command"
              "flakes"
            ];
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

        system.stateVersion = lib.mkDefault "26.05";
      };

    homeManager = { lib, ... }: {
      home.stateVersion = lib.mkDefault "26.05";
    };
  };

  # enable hm by default
  den.schema.user.classes = lib.mkDefault [ "homeManager" ];
}
