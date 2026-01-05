{ pkgs, ... }:
{

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
      settings = {
        ZED_DEBUG_LOG = "/tmp/zed.debug.log";
        ZED_EMAIL_ADDR = [ "root" ];
        ZED_EMAIL_PROG = "${pkgs.mailutils}/bin/mail";
        ZED_EMAIL_OPTS = "-s '@SUBJECT@' @ADDRESS@";

        ZED_NOTIFY_INTERVAL_SECS = 3600;
        ZED_NOTIFY_VERBOSE = true;

        ZED_USE_ENCLOSURE_LEDS = true;
        ZED_SCRUB_AFTER_RESILVER = true;
      };
    };
  };

}