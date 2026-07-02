{ ... }:
{
  imports = [
    ./acme.nix
    ./backups.nix
    ./reverse-proxy.nix
    ./home-assistant.nix
    ./frigate.nix
    ./samba.nix
    ./postfix.nix
    ./pocket-id.nix
    ./immich.nix
  ];
}