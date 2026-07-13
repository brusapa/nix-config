{ den, ... }:
{
  den.aspects.server = {
    includes = [
      den.aspects.secure-boot
      den.aspects.tailscale-server
    ];

    nixos = {
      # Power management
      powerManagement = {
        cpuFreqGovernor = "powersave";
        powertop.enable = true;
      };

      # Prevent suspension/hybernation
      systemd.sleep.settings.Sleep = {
        AllowSuspend = "no";
        AllowHibernation = "no";
        AllowHybridSleep = "no";
        AllowSuspendThenHibernate = "no";
      };

      # Networking
      networking = {
        useDHCP = true;
        useNetworkd = true;
      };
      systemd.network.wait-online = {
        enable = true;
        anyInterface = true;
      };
    };
  };
}
