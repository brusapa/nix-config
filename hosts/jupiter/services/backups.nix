{ lib, pkgs, ... }:
let
  # Source variables
  sourcePool = "zsynology";
  datasets = [ "ramon" ];

  syncoidCommonArgs = [
    # Tell syncoid not to create its own snapshots; rely on sanoid
    "--no-sync-snap"
    # This argument tells syncoid to create a zfs bookmark for the newest snapshot after it got replicated successfully.
    "--create-bookmark"
    # Prune old snapshots on the target that don't exist on the source
    "--delete-target-snapshots"
    # Do not mount newly received datasets
    "--recvoptions=-u"
    # Use raw. End-to-end encrypted backups
    "--sendoptions=-w"
  ];
  
  dailyTargetPool = "zsynobackup";

in {

  # Mount daily backup at boot if present
  fileSystems."/${dailyTargetPool}" = {
    device = dailyTargetPool;
    fsType = "zfs";
    options = [
      "nofail" # Do not block boot if missing
    ];
  };

  services.sanoid = {
    enable = true;
    interval = "hourly";
    templates = {
      standard = {
        autosnap = true;
        autoprune = true;
        daily = 14;
        weekly = 4;
        monthly = 2;
        yearly = 1;
      };
    };

    datasets = lib.listToAttrs (map (dataset: {
      name = "${sourcePool}/${dataset}";
      value.useTemplate = [ "standard" ];
    }) datasets);
  };

  services.syncoid = {
    enable = true;
    interval = "hourly";
    commonArgs = syncoidCommonArgs;
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
      name = "backup-${dataset}-to-daily";
      value = {
        source = "${sourcePool}/${dataset}";
        target = "${dailyTargetPool}/${dataset}";
      };
    }) datasets);
  };
}