{ ... }:
{
  services.apcupsd = {
    enable = true;
    configText = ''
      UPSTYPE usb
      NISIP 0.0.0.0
      BATTERYLEVEL 15
      MINUTES 5  
    '';
  };
}
