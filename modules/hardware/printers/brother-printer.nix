{ modulesPath, pkgs, ... }:

{  
  
  imports = [
    (modulesPath + "/services/hardware/sane_extra_backends/brscan4.nix")
  ];

  # Enable printing service
  services.printing = {
    enable = true;
    drivers = [ pkgs.brlaser ];
    stateless = true;
  };

  environment.systemPackages = [ 
    pkgs.ghostscript
  ];

  hardware.printers = {
    ensurePrinters = [
      {
        name = "Brother_Estudio";
        location = "Estudio";
        deviceUri = "lpd://10.80.0.80/binary_p1";
        model = "drv:///brlaser.drv/brl2710.ppd";
        ppdOptions = {
          PageSize = "A4";
        };
      }
    ];
    ensureDefaultPrinter = "Brother_Estudio";
  };

  # Enable scanner support
  hardware = {
    sane = {
      enable = true;
      brscan4 = {
        enable = true;
        netDevices = {
          home = { model = "MFC-L2710DW"; ip = "10.80.0.80"; };
        };
      };
    };
  };

}