{
  description = "Nix configuration";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "nixpkgs/nixos-24.05";

    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Plasma manager
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs = inputs@ { self, nixpkgs, home-manager, plasma-manager, ... }:
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
            ./hosts/mars/configuration.nix
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
            ./users/bruno/home.nix
          ];
        };
        "gurenda@mars" = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs { inherit system; };
          extraSpecialArgs = {inherit inputs outputs;};
          modules = [
            inputs.plasma-manager.homeManagerModules.plasma-manager
            ./users/gurenda/home.nix
          ];
        };
      };
    };
}