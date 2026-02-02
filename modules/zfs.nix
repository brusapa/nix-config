{ lib, config, pkgs, ... }:
let
  zedRc = "/etc/zfs/zed.d/zed.rc";
in
{

  options.zfs = {
    enable = lib.mkEnableOption "Enable zfs support";

    environmentFile = lib.mkOption {
      type = lib.types.path;
      description = "Secrets environment file";
    };

    ntfy = {
      enable = lib.mkEnableOption "Enable ntfy notifications for ZFS ZED";

      url = lib.mkOption {
        type = lib.types.str;
        example = "https://ntfy.brusapa.com";
        default = "https://ntfy.brusapa.com";
        description = "ntfy URL to publish ZFS events to";
      };

      topic = lib.mkOption {
        type = lib.types.str;
        example = "sun";
        description = "ntfy topic to publish ZFS events to";
      };

      tokenFile = lib.mkOption {
        type = lib.types.path;
        description = "File containing the ntfy access token (token only, no KEY=VALUE)";
      };
    };

  };

  config = lib.mkIf config.zfs.enable {

    systemd.services.zfs-zed = lib.mkIf config.zfs.ntfy.enable {
      preStart = ''
        sed -i '/^ZED_NTFY_ACCESS_TOKEN=/d' ${zedRc}
        echo "ZED_NTFY_ACCESS_TOKEN=$(cat ${config.zfs.ntfy.tokenFile})" >> ${zedRc}
      '';
    };

    environment.systemPackages = [
      pkgs.mailutils
    ];

    boot = {
      supportedFilesystems = [ "zfs" ];
      zfs = {
        devNodes = "/dev/disk/by-id";
        forceImportRoot = false;
      };
    };

    services.zfs = {
      autoScrub = {
        enable = true;
        interval = "Mon *-*-* 22:00:00";
      };
      zed = {
        enableMail = true;
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


          # Ntfy
          (lib.mkIf config.zfs.ntfy.enable {
            ZED_NTFY_URL=config.zfs.ntfy.url;
            ZED_NTFY_TOPIC=config.zfs.ntfy.topic;
          })
        ];
      };
    };

    # Enable monitoring if prometheus is enabled on the system
    services.prometheus.exporters.zfs = lib.mkIf config.services.prometheus.enable {
      enable = true;
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
}