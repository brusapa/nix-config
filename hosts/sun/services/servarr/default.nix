{ ... }:
{
  imports = [
    ./sonarr.nix
    ./radarr.nix
    ./jackett.nix
    ./jellyfin.nix
    ./vpn.nix
    ./profilarr.nix
    ./serr.nix
    ./unpackerr.nix
    ./qbittorrent.nix
  ];

  users.groups.media = {
    gid = 169;
    members = [ "bruno" ];
  };

  systemd.tmpfiles.rules = [
    "d /zstorage/media 2775 root media - -"
  ];
}
