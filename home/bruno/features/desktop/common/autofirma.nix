{ inputs, config, pkgs, ... }:

{

  imports = [
    inputs.autofirma-nix.homeManagerModules.default
  ];


  # Enable AutoFirma with Firefox integration
  programs.autofirma = {
    enable = true;
    firefoxIntegration.profiles = {
      default = {
        enable = true;
      };
    };
  };
  
  # DNIeRemote for using smartphone as DNIe reader
  programs.dnieremote = {
    enable = true;
  };

  # FNMT certificate configurator
  programs.configuradorfnmt = {
    enable = true;
    firefoxIntegration.profiles = {
      default = {
        enable = true;
      };
    };
  };
  
  # Configure Firefox
  programs.firefox = {
    enable = true;
    policies = {
      SecurityDevices = {
        "OpenSC PKCS11" = "${pkgs.opensc}/lib/opensc-pkcs11.so";
        "DNIeRemote" = "${config.programs.dnieremote.finalPackage}/lib/libdnieremotepkcs11.so";
      };
    };
    profiles.default = {
      id = 0;
    };
  };
}
