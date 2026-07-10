{ inputs, ... }:
{
  den.aspects.secure-boot.nixos = { pkgs, lib, ... }: {
    imports = [ 
      inputs.lanzaboote.nixosModules.lanzaboote 
    ];
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
      pkiBundle = "/var/lib/sbctl";
      autoGenerateKeys.enable = true;
      autoEnrollKeys.enable = true;
    };
  };
}