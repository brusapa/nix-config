{ ... }:
{
  imports = [
    ./sonarr.nix
    ./radarr.nix
    ./jackett.nix
    ./jellyfin.nix
    ./vpn.nix
    ./profilarr.nix
  ];
}