{ ... }:
{
  imports = [
    ../../../modules/myservices/wallaos.nix
    ./pocket-id.nix
    ./actual-budget.nix
    ./homarr.nix
    ./miniflux.nix
  ];

  wallaos = {
    enable = true;
    version = "4.5.0";
  };
}