{
  inputs.nixpkgs = "github:nixos/nixpkgs/nixpkgs-unstable";
  inputs.darwin = "github:nix-darwin/nix-darwin";

  outputs = inputs:
  {
    # all your config, most importantly a NixOS like `igloo`:
    nixosConfigurations.igloo = lib.nixosSystem {
      modules = [
         <all your current NixOS modules>
      ];
    };
  };
}