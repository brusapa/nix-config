{ den, ... }:
{
  den.hosts.x86_64-linux.pluto = {
    role = "server";
    users.bruno = { };
    swapSizeGiB = 2;
  };

  den.aspects.pluto = {
    includes = [
      # Role
      den.aspects.server

      # Other features
      den.aspects.pangolin-server
      den.aspects.beszelAgent
    ];

    nixos = {
      boot = {
        loader.systemd-boot.enable = true;
        initrd.availableKernelModules = [
          "ata_piix"
          "uhci_hcd"
          "virtio_pci"
          "sr_mod"
          "virtio_blk"
        ];
      };

      services.qemuGuest.enable = true;

      nix.settings.trusted-public-keys = [
        "sun:odzSB/QtGOOpZsjB+ARawouX81dLyv1zdeHGE0byKQ4="
      ];

      # Optimise for generation size
      documentation.nixos.enable = false;
      documentation.man.enable = false;
      documentation.doc.enable = false;
      documentation.info.enable = false;

      sops.defaultSopsFile = ./secrets.yaml;

      system.stateVersion = "26.05";
    };
  };
}
