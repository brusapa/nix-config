{ pkgs, ... }: 

{
  imports = [
    ./locale.nix
    ./gpg-agent.nix
    ./openssh.nix
    ./nix-ld.nix
  ];

  # Enable experimental features
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  hardware.enableRedistributableFirmware = true;

  # Store optimization
  nix.settings.auto-optimise-store = true;

  # Garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than +5";
  };

  # Basic packages

  programs.fish.enable = true;

  environment.systemPackages = with pkgs; [
    home-manager
    wget
    git
    usbutils
    pciutils
    unrar
    pv
  ];
}
