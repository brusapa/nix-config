{ inputs, outputs, pkgs, ... }: 

{
  imports = [
    ./locale.nix
    ./openssh.nix
    ./nix-ld.nix
  ];

  # Enable experimental features
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  hardware.enableRedistributableFirmware = true;

  # Basic packages
  environment.systemPackages = with pkgs; [
    home-manager
    wget
    git
    usbutils
    pciutils
    unrar
  ];
}