{ self, ... }:
{
  den.aspects.jupiter.nixos =
    { lib, config, ... }:
    let
      # Source variables
      sourceRemote = "zfspuller@sun.brusapa.com:zstorage";
      datasets = [
        "users"
        "photos"
        "paperless"
        "internal-backups"
      ];
    in
    {
      sops = {
        secrets = {
          zfspuller-private-key = {
            sopsFile = ../secrets.yaml;
            owner = config.services.syncoid.user;
            group = config.services.syncoid.group;
          };
        };
      };

      programs.ssh.knownHosts."sun.brusapa.com".publicKeyFile = self + "/hosts/sun/host-key.pub";

      services.syncoid = {
        enable = true;
        sshKey = config.sops.secrets."zfspuller-private-key".path;
        interval = "*-*-* *:15:00";
        commands = lib.listToAttrs (
          map (dataset: {
            name = "backup-sun-${dataset}";
            value = {
              source = "${sourceRemote}/${dataset}";
              target = "zleioa/sun/${dataset}";
              sendOptions = "w";
              recvOptions = "u";
              extraArgs = [
                # Tell syncoid not to create its own snapshots; rely on sanoid
                "--no-sync-snap"
                # This argument tells syncoid to create a zfs bookmark for the newest snapshot after it got replicated successfully.
                "--create-bookmark"
              ];
            };
          }) datasets
        );
      };

      services.sanoid = {
        enable = true;
        datasets = lib.listToAttrs (
          map (
            dataset:
            lib.nameValuePair "zleioa/sun/${dataset}" {
              autosnap = false;
              autoprune = true;
              hourly = 48;
              daily = 60;
              weekly = 20;
              monthly = 24;
              yearly = 5;
            }
          ) datasets
        );
      };
    };
}
