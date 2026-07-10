{ den, ... }:
{
  den.aspects.workstation = {
    includes = [
      den.aspects.secure-boot
      den.aspects.quiet-boot
      den.aspects.kde
      den.aspects.yubikey
      den.aspects.samba-client
      den.aspects.tailscale-client
      den.aspects.libreoffice
      den.aspects.localsend
    ];

    nixos = {
      # Use network manager to manage network connections.
      networking.networkmanager.enable = true;
      systemd.services.NetworkManager-wait-online.enable = false;
    };
  };

}