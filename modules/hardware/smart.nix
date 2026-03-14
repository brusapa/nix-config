{ lib, config, pkgs, ... }:
{
  environment.systemPackages =  with pkgs; [
    smartmontools # SMART cli support
  ];

  # SMART checks
  services.smartd = {
    enable = true;
    notifications = {
      # TODO: Enable only when mail is working
      mail.enable = true;
    };
  };

   # Enable monitoring if prometheus is enabled on the system
  services.prometheus.exporters.smartctl = lib.mkIf config.services.prometheus.enable {
    enable = true;
  };
  services.prometheus.scrapeConfigs = lib.mkIf config.services.prometheus.enable [
    {
      job_name = "smartctl";
      static_configs = [{
        targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.smartctl.port}" ];
      }];
    }
  ];
}