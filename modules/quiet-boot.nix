{ ... }:
{
  boot = {
    initrd.verbose = false;
    consoleLogLevel = 0;
    kernelParams = [ "quiet" "udev.log_level=3" ];
    plymouth = {
      enable = true;
      theme = "breeze";
    };
  };
}