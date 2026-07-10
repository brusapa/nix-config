{ den, ... }:
{
  den.hosts.x86_64-linux.jupiter = {
    role = "server";
    users = {
      bruno = {};
      ramon = {};
    };
    swapSizeGiB = 32;
  };

  den.aspects.jupiter = {
    includes = [
      # Role
      den.aspects.server

      # Other features
      den.aspects.acme
      den.aspects.zfs
      den.aspects.containers
      den.aspects.reverse-proxy
      den.aspects.mail-server
      den.aspects.pocket-id

      # Hardware
      den.aspects.amd-cpu
      den.aspects.apcupsd
    ];

    nixos = 
      { pkgs, ... }:
      {
        # ZFS related options
        zfs = {
          extraPools = [ "znvme" "zleioa" ];
          autoSnapshots = [
            {
              pool = "zleioa";
              datasets = [
                "users"
                "immich"
              ];
            }
          ];
          pullerAuthorizedSshKeys = [
            ../sun/zfspuller-key.pub
          ];
        };
        # Unique host identifier used for ZFS
        networking.hostId = "e5501645";

        sops.defaultSopsFile = ./secrets.yaml;

        reverseProxy.baseDomain = "leioa.brusapa.com";

        system.stateVersion = "24.05";
      };
  };
}