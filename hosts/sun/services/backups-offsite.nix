{ config, lib, ... }:
{

  options.backup-offsite-landabarri.job = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule {
        options = {
          paths = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            description = "Paths to back up";
          };
          exclude = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            description = "Paths to exclude from backup";
          };
          backupPrepareCommand = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "Optional commands to  run before backup";
          };
        };
      }
    );
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

    assertions = lib.mkMerge [
      [
        {
          # Check that there is at least one backup job configured
          assertion = builtins.length (builtins.attrNames config.backup-offsite-landabarri.job) > 0;
          message = "You must define at least one backup job";
        }
      ]
      (builtins.map (name: {
        assertion = config.backup-offsite-landabarri.job.${name}.paths != [ ];
        message = "Backup configuration '${name}' has no paths defined!";
      }) (builtins.attrNames config.backup-offsite-landabarri.job))
    ];

    # Restic backups configuration
    services.restic.backups = lib.mkAfter (
      lib.listToAttrs (
        # Daily backups to internal disk
        lib.mapAttrsToList (name: job: {
          name = "${name}-offsite-landabarri";
          value = {
            repository = "sftp:sun@nas.landabarri.brusapa.com:/BackupNasSasiarte/${name}";
            passwordFile = config.sops.secrets.backup-password.path;
            initialize = true;

            paths = job.paths;
            exclude = job.exclude;
            backupPrepareCommand = job.backupPrepareCommand;
            timerConfig = {
              OnCalendar = "Mon *-*-* 01:00:00";
              Persistent = true;
              RandomizedDelaySec = "4h";
            };

            pruneOpts = [
              "--keep-daily 7"
              "--keep-monthly 12"
            ];
          };
        }) config.backup-offsite-landabarri.job
      )
    );

    # Set the health-checks for the backups
    external-health-check.job = lib.mkMerge [
      (
        lib.mapAttrs' (name: resticCfg:
          lib.nameValuePair name {
            name = name;
            group = "backups";
            token = "secret";
          }
        ) config.services.restic.backups
      )
    ];

    # Auxiliary systemd services and jobs customizations
    systemd.services = lib.mkMerge [
      # Create the on success systemd services
      (lib.mapAttrs' (name: _: 
        let
          serviceName = "restic-backups-${name}-onSuccess";
        in
        lib.nameValuePair serviceName {
          script = ''
            /run/current-system/sw/bin/curl -X POST -H "Authorization: Bearer secret" https://gatus.brusapa.com/api/v1/endpoints/backups_${name}/external?success=true
          '';
        }
      ) config.services.restic.backups)

      # Create the on failure systemd services
      (lib.mapAttrs' (name: _: 
        let
          serviceName = "restic-backups-${name}-onFailure";
        in
        lib.nameValuePair serviceName {
          script = ''
            /run/current-system/sw/bin/curl -X POST -H "Authorization: Bearer secret" https://gatus.brusapa.com/api/v1/endpoints/backups_${name}/external?success=false
          '';
        }
      ) config.services.restic.backups)

      # Inject the per-restic-backup onSuccess onFailure handlers
      (lib.mapAttrs' (name: _: 
        let
          serviceName = "restic-backups-${name}";
        in
        lib.nameValuePair serviceName {
          onFailure = [ 
            "${serviceName}-onFailure.service"
          ];
          onSuccess = [
            "${serviceName}-onSuccess.service"
          ];
        }
      ) config.services.restic.backups)
    ];

  };
}
