{ lib, pkgs, ... }:
let
  # Source variables
  sourcePool = "zstorage";
  datasets = [ "users" "paperless" "photos" "internal-backups" ];

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
  
  dailyTargetPool = "daily-backup";

  weeklyTargetPool = "weekly-backup";
  weeklyUsbSerial = "WD-WXE2E11DE846";

  # Script that performs the import → syncoid → export sequence.
  # IMPORTANT: %i is expanded by systemd in ExecStart. The script
  # reads the target pool name as $1.
  syncScript = pkgs.writeShellScript "usb-zfs-sync.sh" ''
    set -euo pipefail
    TARGET_POOL="$1"
    echo "[usb-zfs-sync] Backup started for $TARGET_POOL"

    # Import the pool if it isn't already imported (-N to avoid mounting).
    if ! ${pkgs.zfs}/bin/zpool list -H -o name | grep -qx "$TARGET_POOL"; then
      echo "[usb-zfs-sync] Importing pool: $TARGET_POOL"
      ${pkgs.zfs}/bin/zpool import -N -f "$TARGET_POOL" || {
        echo "[usb-zfs-sync] Pool $TARGET_POOL not found or import failed"
        exit 1
      }
    fi

    echo "[usb-zfs-sync] Starting replications to pool $TARGET_POOL ..."
    for dataset in ${lib.concatStringsSep " " datasets}; do
      ${pkgs.sanoid}/bin/syncoid \
        ${lib.escapeShellArgs syncoidCommonArgs} \
        ${sourcePool}/"$dataset" \
        "$TARGET_POOL/$dataset"
    done

    echo "[usb-zfs-sync] Replications finished."

    # Export the pool so it’s safely removable.
    echo "[usb-zfs-sync] Exporting pool $TARGET_POOL"
    ${pkgs.zfs}/bin/zpool export "$TARGET_POOL" || true
    echo "[usb-zfs-sync] Backup finished for $TARGET_POOL"
  '';
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
        hourly = 8;        # Keep 8 hourly snapshots
        daily = 7;         # Keep 7 daily snapshots
        weekly = 4;        # Keep 4 weekly snapshots
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

  # ---- On-plug USB replication unit (triggered by udev) ----
  systemd.services."usb-zfs-sync@" = {
    description = "Replicate to USB ZFS pool %I on plug";
    after = [ "zfs-import.target" "local-fs.target" ];
    wantedBy = [ ]; # udev will start it; don’t start automatically
    serviceConfig = {
      Type = "oneshot";
      TimeoutStartSec = 0;
      # CRITICAL: Expand %i here, not inside the script.
      ExecStart = "${syncScript} %i";
    };
  };

  # ---- udev rule: start the job when the USB disk appears ----
  # Match the DISK (not partitions), and use ATTRS{serial} for robust USB enclosures.
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="block", ENV{DEVTYPE}=="disk", \
      ENV{ID_BUS}=="usb", ATTRS{serial}=="${weeklyUsbSerial}", \
      TAG+="systemd", ENV{SYSTEMD_WANTS}+="usb-zfs-sync@${weeklyTargetPool}.service"
  '';
}