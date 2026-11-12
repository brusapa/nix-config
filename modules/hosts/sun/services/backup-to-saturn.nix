{
  den.aspects.sun.nixos =
    { lib, ... }:
    let
      # Source variables
      sourceRemote = "zstorage";
      datasets = [
        "users"
        "photos"
        "paperless"
        "internal-backups"
      ];
    in
    {
      services.syncoid = {
        enable = true;
        commands = lib.listToAttrs (
          map (dataset: {
            name = "backup-to-saturn-${dataset}";
            value = {
              source = "${sourceRemote}/${dataset}";
              target = "zsaturn/sun/${dataset}";
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
    };
}
