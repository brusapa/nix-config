{
  description = "Nix configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.11";

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
      url = "github:nix-community/home-manager/release-24.11";
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

    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";

    catppuccin.url = "github:catppuccin/nix";
  };

  outputs = inputs@ { self, nixpkgs, disko, lanzaboote, nixos-hardware, home-manager, plasma-manager, firefox-addons, nvf, nixos-wsl, nix-flatpak, catppuccin, ... }:
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
            catppuccin.nixosModules.catppuccin
            ./modules/secure-boot.nix
            ./hosts/mars

            home-manager.nixosModules.home-manager
            {
              home-manager.extraSpecialArgs = {inherit inputs;};
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.sharedModules = [ 
                nix-flatpak.homeManagerModules.nix-flatpak
                plasma-manager.homeManagerModules.plasma-manager
                nvf.homeManagerModules.default
                catppuccin.homeManagerModules.catppuccin
              ];
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
            catppuccin.nixosModules.catppuccin
            ./modules/secure-boot.nix
            ./hosts/mercury

            home-manager.nixosModules.home-manager
            {
              home-manager.extraSpecialArgs = {inherit inputs;};
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.sharedModules = [ 
                nix-flatpak.homeManagerModules.nix-flatpak
                plasma-manager.homeManagerModules.plasma-manager
                nvf.homeManagerModules.default
                catppuccin.homeManagerModules.catppuccin
              ];
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
            catppuccin.nixosModules.catppuccin
            ./hosts/wsl

            home-manager.nixosModules.home-manager
            {
              home-manager.extraSpecialArgs = {inherit inputs;};
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.sharedModules = [ 
                nvf.homeManagerModules.default
                catppuccin.homeManagerModules.catppuccin
              ];

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
            catppuccin.nixosModules.catppuccin
            ./hosts/mercury/configuration.nix

            home-manager.nixosModules.home-manager
            {
              home-manager.extraSpecialArgs = {inherit inputs;};
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.sharedModules = [ 
                nix-flatpak.homeManagerModules.nix-flatpak
                plasma-manager.homeManagerModules.plasma-manager
                nvf.homeManagerModules.default
                catppuccin.homeManagerModules.catppuccin
              ];
              home-manager.backupFileExtension = "backup";

              home-manager.users.bruno = import ./home/bruno/mercury.nix;
              home-manager.users.gurenda = import ./home/gurenda/home.nix;
            } 
          ];
        };
      };
    };
}
