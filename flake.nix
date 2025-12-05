{
  description = "Nix configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.3";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix.url = "github:Mic92/sops-nix";

    autofirma-nix = {
      url = "github:nix-community/autofirma-nix/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixarr.url = "github:rasmus-kirk/nixarr";

    nix-flatpak.url = "github:gmodena/nix-flatpak";
  };

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  outputs = inputs@{
    self,
    nixpkgs,
    flake-parts,
    disko,
    lanzaboote,
    nixos-hardware,
    home-manager,
    plasma-manager,
    firefox-addons,
    nixpkgs-unstable,
    nixos-wsl,
    sops-nix,
    autofirma-nix,
    nixarr,
    nix-flatpak,
    ...
  }:
  flake-parts.lib.mkFlake { inherit inputs; } ({
    # define the systems for which we want to compute things
    systems = [ "x86_64-linux" "aarch64-linux" ];

    # flake-parts passes { self, inputs, lib, ... } here
    perSystem = { system, pkgs, ... }: {
      # You can put perSystem packages, devShells, checks, etc. here later.
      # Example:
      # packages.hello = pkgs.hello;
    };

    flake = let
      makeNixosConfig = { hostname, users, system ? "x86_64-linux" }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/${hostname}
            (import ./modules/home-manager-config.nix {
              inherit hostname users;
            })
          ];
        };
    in {
      overlays = import ./overlays { inherit inputs; };

      # NixOS configurations
      nixosConfigurations = {
        sun = makeNixosConfig {
          hostname = "sun";
          users = [ "bruno" ];
        };

        mars = makeNixosConfig {
          hostname = "mars";
          users = [ "bruno" "gurenda" ];
        };

        mercury = makeNixosConfig {
          hostname = "mercury";
          users = [ "bruno" "gurenda" ];
        };

        wsl = makeNixosConfig {
          hostname = "wsl";
          users = [ "bruno" ];
        };

        rpi-landabarri = makeNixosConfig {
          system = "aarch64-linux";
          hostname = "rpi-landabarri";
          users = [ "bruno" ];
        };
      };
    };
  });
}
