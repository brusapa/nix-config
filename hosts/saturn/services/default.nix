{ ... }:
{
  imports = [
    ./acme.nix
    ./reverse-proxy.nix
    ./home-assistant.nix
    ./frigate.nix
  ];
}