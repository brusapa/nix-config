{ ... }:
{

  # Power management
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "powersave";
    powertop.enable = true;
  };

  # Prevent suspension/hybernation
  systemd.sleep.settings.Sleep = 
  { 
    AllowSuspend = "no";
    AllowHibernation = "no";
    AllowHybridSleep = "no";
    AllowSuspendThenHibernate = "no";
  };  
}