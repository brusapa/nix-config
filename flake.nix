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
  };

  outputs = inputs@ { self, nixpkgs, disko, lanzaboote, nixos-hardware, home-manager, plasma-manager, firefox-addons, ... }:
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

              home-manager.users.bruno = import ./home/bruno/home.nix;
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
            ./hosts/mercury/configuration.nix

            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.sharedModules = [ plasma-manager.homeManagerModules.plasma-manager ];

              home-manager.users.bruno = import ./home/bruno/home.nix;
              home-manager.users.gurenda = import ./home/gurenda/home.nix;
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
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.sharedModules = [ plasma-manager.homeManagerModules.plasma-manager ];

              home-manager.users.bruno = import ./home/bruno/home.nix;
              home-manager.users.gurenda = import ./home/gurenda/home.nix;
            } 
          ];
        };
      };

      # Home manager configurations
      # Available through 'home-manager switch --flake .#username@hostname'
      homeConfigurations = {
        "bruno@mars" = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs { inherit system; };
          extraSpecialArgs = {inherit inputs outputs;};
          modules = [
            inputs.plasma-manager.homeManagerModules.plasma-manager
            ./home/bruno/home.nix
          ];
        };
        "bruno@mercury" = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs { inherit system; };
          extraSpecialArgs = {inherit inputs outputs;};
          modules = [
            inputs.plasma-manager.homeManagerModules.plasma-manager
            ./home/bruno/home.nix
          ];
        };
        "gurenda@mars" = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs { inherit system; };
          extraSpecialArgs = {inherit inputs outputs;};
          modules = [
            inputs.plasma-manager.homeManagerModules.plasma-manager
            ./home/gurenda/home.nix
          ];
        };
        "gurenda@mercury" = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs { inherit system; };
          extraSpecialArgs = {inherit inputs outputs;};
          modules = [
            inputs.plasma-manager.homeManagerModules.plasma-manager
            ./home/gurenda/home.nix
          ];
        };
      };
    };
}