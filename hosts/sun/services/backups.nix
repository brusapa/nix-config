{ config, lib, ... }:
{

  options.backup.job = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule {
      options = {
        paths = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [];
          description = "Paths to back up";
        };
        exclude = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [];
          description = "Paths to exclude from backup";
        };
        backupPrepareCommand = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "Optional commands to  run before backup";
        };
      };
    });
  };

  config = {
    # Import the needed secrets
    sops = {
      secrets = {
        backup-password = {
          sopsFile = ../secrets.yaml;
        };
      };
    };

    # TODO: Validar que al menos haya un backup.job configurado
    # TODO: Validar que no se repitan los job names 
    # TODO: Validar que no haya ningún backup.job con paths vacío

    services.restic.backups = lib.listToAttrs (
      lib.mapAttrsToList (name: job: { 
        name = "${name}-daily-internal";
        value = {
          repository = "/mnt/internalBackup/${name}";
          passwordFile = config.sops.secrets.backup-password.path;
          initialize = true;

          paths = job.paths;
          exclude = job.exclude;
          backupPrepareCommand = job.backupPrepareCommand;
          timerConfig = {
            OnCalendar = "01:00";
            Persistent = true;
            RandomizedDelaySec = "4h";
          };

          pruneOpts = [
            "--keep-daily 7"
            "--keep-monthly 12"
          ];
        };
      }) config.backup.job
    );
  };
}
