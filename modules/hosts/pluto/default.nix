{ den, ... }:
{
  den.hosts.x86_64-linux.pluto = {
    role = "server";
    users.bruno = { };
    swapSizeGiB = 1;
  };

  den.aspects.pluto = {
    includes = [
      # Role
      den.aspects.server

      # Other features
      den.aspects.pangolin-server
    ];

    nixos = { lib, ... }: {
      boot.loader = {
        efi.efiSysMountPoint = "/boot/efi";
        grub = {
          efiSupport = true;
          efiInstallAsRemovable = true;
          device = "nodev";
        };
      };
      fileSystems."/" =
        { device = "/dev/disk/by-uuid/452e94f8-0a67-4848-8598-f2fa0aaca72d";
          fsType = "ext4";
        };

      fileSystems."/boot/efi" =
        { device = "/dev/disk/by-uuid/A025-EFFE";
          fsType = "vfat";
          options = [ "fmask=0022" "dmask=0022" ];
        };
      boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "virtio_pci" "virtio_blk" ];

      # Optimise for generation size
      hardware.enableRedistributableFirmware = lib.mkForce false;
      documentation.nixos.enable = false;
      documentation.man.enable = false;   # si no necesitas man pages en el servidor
      documentation.doc.enable = false;
      documentation.info.enable = false;

      sops.defaultSopsFile = ./secrets.yaml;

      system.stateVersion = "25.11";
    };
  };
}
