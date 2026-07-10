{ den, ... }:
{
  den.hosts.x86_64-linux.venus = {
    role = "workstation";
    users = {
      bruno = {};
      gurenda = {};
    };
    swapSizeGiB = 32;
  };

  den.aspects.venus = {
    includes = [ 
      # Role
      den.aspects.workstation

      # Other features
      den.aspects.gaming
      den.aspects.sunshine

      # Hardware
      den.aspects.intel-cpu
      den.aspects.amd-gpu
      den.aspects.bluetooth
      den.aspects.logitech
      den.aspects.brother-printer
    ];

    nixos = { pkgs, lib, config, ...}: {
      # Unique host identifier used for ZFS
      networking.hostId = "d071c3fc";

      # Enable Wake On Lan
      networking.interfaces.eno1.wakeOnLan.enable = true;
    };
  };
}