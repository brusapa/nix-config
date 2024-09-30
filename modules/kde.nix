{ inputs, lib, config, pkgs, ... }:

{
  # Use network manager to manage network connections.
  networking.networkmanager.enable = true;

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    xkb = {
      layout = "es";
      variant = "";
    };
  };

  environment.systemPackages = with pkgs; [
    kdePackages.isoimagewriter
    kdePackages.skanpage
    kdePackages.kcalc
    kdePackages.krdc
    kdePackages.kleopatra
    kdePackages.kdeconnect-kde
    digikam
    haruna
    kdePackages.kio-fuse #to mount remote filesystems via FUSE
    kdePackages.kio-extras #extra protocols support (sftp, fish and more)
    kdePackages.qtsvg
    kdePackages.qtwayland
  ];

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Unlock KDE wallet on login
  security.pam.services.sddm.kwallet.enable = true;

  programs.partition-manager.enable = true;

}