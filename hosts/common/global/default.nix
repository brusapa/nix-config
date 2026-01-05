{ inputs, pkgs, ... }: 

{
  imports = [
    ./locale.nix
    ./gpg-agent.nix
    ./openssh.nix
    ./nix-ld.nix
    ./sops.nix
    ../users
  ];

  # Enable experimental features
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  # Enable the usage of unstable packages
  nixpkgs.overlays = [ inputs.self.overlays.unstable-packages ];

  hardware.enableRedistributableFirmware = true;

  # Store optimization
  nix.settings.auto-optimise-store = true;

  # Garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than +5";
  };

  # Cachix binary cache
  nix.settings.substituters = [
    "https://nix-community.cachix.org"
    "https://cache.nixos.org/"
  ];
  nix.settings.trusted-public-keys = [
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
  ];

  # Allow appimage-run
  programs.appimage.enable = true;

  # Basic packages
  programs.fish.enable = true;

  environment.systemPackages = with pkgs; [
    home-manager
    wget
    git
    usbutils
    pciutils
    unrar
    pv # Tool for monitoring the progress of data through a pipeline
    smartmontools # SMART cli support
    e2fsprogs # Tools for creating and checking ext2/ext3/ext4 filesystems
  ];

  # SMART checks
  services.smartd = {
    enable = true;
    notifications = {
      mail.enable = true;
    };
  };

  # Whether to generate the manual page index caches. This allows searching for a page or keyword using utilities like apropos(1) and the -k option of man(1).
  # Fish enables it by default, but takes a really long timetime.
  documentation.man.generateCaches = false;

  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
}
