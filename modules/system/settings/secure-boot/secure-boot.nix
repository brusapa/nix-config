# ═══════════════════════════════════════════════════════════════════════════
# SECURE BOOT (LANZABOOTE)
# ═══════════════════════════════════════════════════════════════════════════
# Secure boot support using lanzaboote
# Usage: Import flake.modules.nixos.secureboot in your configuration
{ inputs, ... }:
{
  flake.modules.nixos.secureboot = { pkgs, lib, ... }: {
    imports = [
      inputs.lanzaboote.nixosModules.lanzaboote
    ];
    
    boot.lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
      autoGenerateKeys.enable = true;
      autoEnrollKeys = {
        enable = true;
        autoReboot = true;
      };
    };
    
    environment.systemPackages = [
      pkgs.sbctl 
    ];
  };
}