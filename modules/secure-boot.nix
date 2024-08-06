{ inputs, lib, config, pkgs, ... }:

{

  environment.systemPackages = with pkgs; [
    sbctl # For debugging and troubleshooting Secure Boot.
    tpm2-tss
  ];

  # Lanzaboote currently replaces the systemd-boot module.
  boot.bootspec.enable = true;
  boot.initrd.systemd.enable = true;
  boot.loader.systemd-boot.enable = lib.mkForce false;

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/etc/secureboot";
  };

}