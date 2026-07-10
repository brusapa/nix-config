{ den, inputs, ... }:
{
  den.hosts.x86_64-linux.mercury = {
    role = "workstation";
    users = {
      bruno = {};
      gurenda = {};
    };
    swapSizeGiB = 32;
  };

  den.aspects.mercury = {
    includes = [ 
      # Role
      den.aspects.workstation

      # Other features
      den.aspects.gaming

      # Hardware
      den.aspects.amd-cpu
      den.aspects.amd-gpu
      den.aspects.bluetooth
      den.aspects.logitech
      den.aspects.brother-printer
    ];

    nixos = { pkgs, ... }: {

      imports = [
        inputs.nixos-hardware.nixosModules.framework-13-7040-amd
      ];

      # USB 4 support
      boot.initrd.availableKernelModules = [ "thunderbolt"];

      # Unique host identifier used for ZFS
      networking.hostId = "46b34875";

      # Use fan control
      hardware.fw-fanctrl.enable = true;
    };
  };
}
