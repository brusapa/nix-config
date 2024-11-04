{
  description = "Nix configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.05";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
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

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@ { self, nixpkgs, disko, lanzaboote, nixos-hardware, home-manager, plasma-manager, firefox-addons, nixos-wsl, ... }:
    let
      lib = nixpkgs.lib;
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      inherit (self) outputs;
    in {

      # NixOS configurations
      # Available through 'nixos-rebuild switch --flake .#hostname'
      nixosConfigurations = {
        mars = nixpkgs.lib.nixosSystem {
          specialArgs = {inherit inputs outputs;};
          modules = [
            disko.nixosModules.disko
            lanzaboote.nixosModules.lanzaboote
            ./modules/secure-boot.nix
            ./hosts/mars

            home-manager.nixosModules.home-manager
            {
              home-manager.extraSpecialArgs = {inherit inputs;};
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.sharedModules = [ plasma-manager.homeManagerModules.plasma-manager ];
              home-manager.backupFileExtension = "backup";

              home-manager.users.bruno = import ./home/bruno/mars.nix;
              home-manager.users.gurenda = import ./home/gurenda/home.nix;
            }
          ];
        };
        
        mercury = nixpkgs.lib.nixosSystem {
          specialArgs = {inherit inputs outputs;};
          modules = [
            disko.nixosModules.disko
            lanzaboote.nixosModules.lanzaboote
            ./modules/secure-boot.nix
            ./hosts/mercury

            home-manager.nixosModules.home-manager
            {
              home-manager.extraSpecialArgs = {inherit inputs;};
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.sharedModules = [ plasma-manager.homeManagerModules.plasma-manager ];
              home-manager.backupFileExtension = "backup";

              home-manager.users.bruno = import ./home/bruno/mercury.nix;
              home-manager.users.gurenda = import ./home/gurenda/home.nix;
            }
          ];
        };

        wsl = nixpkgs.lib.nixosSystem {
          specialArgs = {inherit inputs outputs;};
          system = "x86_64-linux";
          modules = [
            nixos-wsl.nixosModules.wsl
            ./hosts/wsl

            home-manager.nixosModules.home-manager
            {
              home-manager.extraSpecialArgs = {inherit inputs;};
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";

              home-manager.users.bruno = import ./home/bruno/wsl.nix;
            }
          ];
        };

        mercury-fresh = nixpkgs.lib.nixosSystem {
          specialArgs = {inherit inputs outputs;};
          modules = [
            disko.nixosModules.disko
            lanzaboote.nixosModules.lanzaboote
            ./hosts/mercury/configuration.nix

            home-manager.nixosModules.home-manager
            {
              home-manager.extraSpecialArgs = {inherit inputs;};
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.sharedModules = [ plasma-manager.homeManagerModules.plasma-manager ];
              home-manager.backupFileExtension = "backup";

              home-manager.users.bruno = import ./home/bruno/mercury.nix;
              home-manager.users.gurenda = import ./home/gurenda/home.nix;
            } 
          ];
        };
      };
    };
}