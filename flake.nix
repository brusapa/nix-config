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
  
    fw-fanctrl = {
      url = "github:TamtamHero/fw-fanctrl/packaging/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = inputs@ { self, nixpkgs, disko, lanzaboote, nixos-hardware, home-manager, plasma-manager, firefox-addons, nvf, nixos-wsl, fw-fanctrl, ... }:
  let
    lib = nixpkgs.lib;
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
    inherit (self) outputs;
    makeNixosConfig = { hostname, users }: nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [
        ./hosts/${hostname}
        (import ./modules/home-manager-config.nix {
          inherit hostname users;
        })
      ];
    };
  in {

    # NixOS configurations
    # Available through 'nixos-rebuild switch --flake .#hostname'
    nixosConfigurations = {
      mars = makeNixosConfig { 
        hostname = "mars";
        users = ["bruno" "gurenda"];
      };
      
      mercury = makeNixosConfig { 
        hostname = "mercury";
        users = ["bruno" "gurenda"];
      };

      venus = makeNixosConfig {
        hostname = "venus";
        users = ["bruno"];
      };

      wsl = makeNixosConfig { 
        hostname = "wsl";
        users = ["bruno"];
      };

      rpi-landabarri = makeNixosConfig { 
        hostname = "rpi-landabarri";
        users = ["bruno"];
      };
    };
  };
}
