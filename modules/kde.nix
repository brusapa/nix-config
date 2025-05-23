{ pkgs, ... }:

{
  # Use network manager to manage network connections.
  networking.networkmanager.enable = true;
  systemd.services.NetworkManager-wait-online.enable = false;

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
    kdePackages.kleopatra
    kdePackages.kdeconnect-kde
    haruna
    kdePackages.kio-fuse #to mount remote filesystems via FUSE
    kdePackages.kio-extras #extra protocols support (sftp, fish and more)
    kdePackages.qtsvg
    kdePackages.qtwayland
  ];

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  environment.plasma6.excludePackages = [ 
    pkgs.kdePackages.discover
    pkgs.kdePackages.elisa
  ];

  # Unlock KDE wallet on login
  security.pam.services.sddm.kwallet.enable = true;

  programs.partition-manager.enable = true;

}