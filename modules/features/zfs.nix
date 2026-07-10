{
  den.aspects.zfs.nixos = { lib, config, pkgs, ... }:
  let
    zedRc = "/etc/zfs/zed.d/zed.rc";
  in
  {
    options.zfs = {
      enable = lib.mkEnableOption "Enable zfs support";

      extraPools = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        description = "Name or GUID of extra ZFS pools that you wish to import during boot.";
      };

    };

    config = lib.mkIf config.zfs.enable {

      environment.systemPackages = [
        pkgs.mailutils
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
