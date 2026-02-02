{
  inputs,
  ...
}:
{
  # sops-encrypted secrets for NixOS and Home Manager
  # https://github.com/Mic92/sops-nix

  flake-file.inputs = {
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    secrets = {
      url = "path:./secrets";
      flake = false;
    };
  };
}