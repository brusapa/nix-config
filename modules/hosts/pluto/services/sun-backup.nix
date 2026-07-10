{
  den.aspects.pluto.nixos = { lib, config, ... }:
    let
      # Source variables
      sourcePool = "zfspuller@sun.brusapa.com:zstorage";
      datasets = [ "users" "paperless" "photos" "internal-backups" ];
    in {

      # Import the needed secrets
      sops = {
        secrets = {
          sun-zfspuller-private-key = {
            sopsFile = ../secrets.yaml;
            owner = config.services.syncoid.user;
            group = config.services.syncoid.group;
            mode = "0600";
          };
        };
      };

      services.syncoid = {
        enable = true;
        interval = "hourly";
        sshKey = config.sops.secrets.sun-zfspuller-private-key.path;
        localTargetAllow = [
          "change-key"
          "compression"
          "create"
          "destroy"
          "mount"
          "mountpoint"
          "receive"
          "rollback"
        ];

        commands = lib.listToAttrs (map (dataset: {
          name = "backup-sun-${dataset}";
          value = {
            source = "${sourcePool}/${dataset}";
            target = "zbackup/${dataset}";
            sendOptions="w";
            recvOptions="u";
            extraArgs = [
              # Tell syncoid not to create its own snapshots; rely on sanoid
              "--no-sync-snap"
              # This argument tells syncoid to create a zfs bookmark for the newest snapshot after it got replicated successfully.
              "--create-bookmark"
              # Prune old snapshots on the target that don't exist on the source
              "--delete-target-snapshots"
            ];
          };
        }) datasets);
      };

    };
}