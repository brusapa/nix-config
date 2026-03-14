{ ... }:
{
  imports = [
    ../../../modules/myservices/wallaos.nix
    ./pocket-id.nix
    ./actual-budget.nix
    ./dawarich.nix
    ./homarr.nix
    ./miniflux.nix
    ./donetick.nix
  ];

  wallaos = {
    enable = true;
    version = "4.5.0";
  };
}