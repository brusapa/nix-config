{ inputs, lib, config, pkgs, ... }:

{  
  
  # Enable printing service
  services.printing.enable = true;

  # Manually add the driver for the Brother MFC-L2710DW printer
  services.printing.drivers = [
    (pkgs.callPackage ./mfcl2710dw.nix {})
  ];

  hardware.printers = {
    ensurePrinters = [
      {
        name = "Brother_Estudio";
        location = "Estudio";
        deviceUri = "lpd://10.80.0.80/binary_p1";
        model = "brother-MFCL2710DW-cups-en.ppd";
        ppdOptions = {
          PageSize = "A4";
        };
      }
    ];
    ensureDefaultPrinter = "Brother_Estudio";
  };

}