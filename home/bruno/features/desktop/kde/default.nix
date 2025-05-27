{ inputs, lib, pkgs, ... }:

{

  imports = [
    inputs.plasma-manager.homeManagerModules.plasma-manager
    ../common
    ./konsole
    ./kate.nix
    ./plasma-settings.nix
  ];


  home.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    jetbrains-mono
  ];

}
