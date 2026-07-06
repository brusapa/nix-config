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
    ./brother-scanner.nix
    ./mealie.nix
    ./jupiter-backup.nix
    ./claude-code-container.nix
  ];

  wallaos = {
    enable = true;
    version = "4.9.6";
  };
}