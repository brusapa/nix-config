{
  den.aspects.kde = {
    nixos = { pkgs, ... }:
    {
      # Enable the KDE Plasma Desktop Environment.
      services.displayManager.plasma-login-manager.enable = true;
      services.xserver.xkb.layout = "es";
      services.desktopManager.plasma6.enable = true;

      # Unlock KDE wallet on login
      security.pam.services.plasmalogin.kwallet.enable = true;

      # Extra software
      programs.partition-manager.enable = true;
      programs.kdeconnect.enable = true;

      environment.systemPackages = with pkgs; [
        kdePackages.isoimagewriter
        kdePackages.skanpage
        kdePackages.kcalc
        kdePackages.kleopatra
        haruna
        kdePackages.kio-fuse #to mount remote filesystems via FUSE
        kdePackages.kio-extras #extra protocols support (sftp, fish and more)
        kdePackages.qtsvg
        kdePackages.qtwayland
      ];

      environment.plasma6.excludePackages = with pkgs.kdePackages; [ 
        discover
        elisa
      ];

      # Audio
      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
      };
    };
  };
}

