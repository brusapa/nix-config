# TODO: Incluir automáticamente mail-server
{
  den.aspects.zfs.nixos = { lib, config, pkgs, ... }:
  {
    options.zfs = {
      extraPools = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        description = "Name or GUID of extra ZFS pools that you wish to import during boot.";
      };

      autoSnapshots = lib.mkOption {
        type = lib.types.listOf (lib.types.submodule {
          options = {
            pool = lib.mkOption {
              type = lib.types.str;
              description = "Name of the source ZFS pool";
            };

            datasets = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
              description = "Which datasets to create snapshots for";
            };
          };
        });
        default = [ ];
        description = "ZFS pool to create snapshots for";
      };

      pullerAuthorizedSshKeys = lib.mkOption {
        type = lib.types.listOf lib.types.path;
        default = [ ];
        description = ''
          A list of files each containing one OpenSSH public key that should be
          added to the ZFS puller authorized keys.
        '';
      };

    };

    config = 
    let
      allDatasetPaths = lib.concatMap
        (sp: map (dataset: "${sp.pool}/${dataset}") sp.datasets) config.zfs.autoSnapshots;
    in {
      environment.systemPackages = [
        pkgs.mailutils
        pkgs.restic
        pkgs.lzop
        pkgs.mbuffer
      ];

      boot = {
        supportedFilesystems = [ "zfs" ];
        zfs = {
          extraPools = config.zfs.extraPools;
          forceImportRoot = false;
          passwordTimeout = 60; # 1 minute
        };
      };

      services.zfs = {
        autoScrub = {
          enable = true;
          interval = "Mon *-*-* 22:00:00";
        };
        zed = {
          enableMail = config.services.mail.sendmailSetuidWrapper != null;
          settings = lib.mkMerge [
            {
              ZED_DEBUG_LOG = "/tmp/zed.debug.log";
              ZED_EMAIL_ADDR = [ "root" ];
              ZED_EMAIL_PROG = "${pkgs.mailutils}/bin/mail";
              ZED_EMAIL_OPTS = "-s '@SUBJECT@' @ADDRESS@";

              ZED_NOTIFY_INTERVAL_SECS = 3600;
              ZED_NOTIFY_VERBOSE = true;

              ZED_USE_ENCLOSURE_LEDS = true;
              ZED_SCRUB_AFTER_RESILVER = true;
            }
          ];
        };
      };

      # Snapshot management
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

        datasets = lib.listToAttrs (map (path: {
          name = path;
          value.useTemplate = [ "standard" ];
        }) allDatasetPaths);
      };

      # Syncoid puller user configuration      
      users.groups.zfspuller = {};
      users.users.zfspuller = {
        group = "zfspuller";
        extraGroups = [
          "ssh-login"
        ];
        isSystemUser = true;
        shell = pkgs.bashInteractive;
        openssh.authorizedKeys.keysFiles = config.zfs.pullerAuthorizedSshKeys;
      };

      # Enable monitoring if prometheus is enabled on the system
      services.prometheus.exporters.zfs = lib.mkIf config.services.prometheus.enable {
        enable = true;
        extraFlags = [
          "--collector.dataset-snapshot"
        ];
      };
      services.prometheus.scrapeConfigs = lib.mkIf config.services.prometheus.enable [
        {
          job_name = "${config.networking.hostName}_zfs";
          static_configs = [{
            targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.zfs.port}" ];
          }];
        }
      ];
    };
  };
}
