{
  den.aspects.sun.nixos = 
    { lib, config, ... }:
    let
      # Source variables
      sourcePool = "zfspuller@jupiter.brusapa.com:zleioa";
      datasets = [ "users" "immich" ];
    in {
      services.syncoid = {
        commands = lib.listToAttrs (map (dataset: {
          name = "backup-jupiter-${dataset}";
          value = {
            source = "${sourcePool}/${dataset}";
            target = "zstorage/jupiter-${dataset}";
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