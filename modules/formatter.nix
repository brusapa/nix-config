{ inputs, lib, ... }:
{
  imports = [
    (inputs.treefmt-nix.flakeModule or { })
  ];

  flake-file.inputs.treefmt-nix = {
    url = "github:numtide/treefmt-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  # `nix fmt` formats the repo and `nix flake check` fails on unformatted files.
  # Guarded so `nix run .#write-flake` can add the input the first time.
  perSystem = lib.optionalAttrs (inputs ? treefmt-nix) {
    treefmt.programs.nixfmt.enable = true;
  };
}
