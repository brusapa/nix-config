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
    nerdfonts
    jetbrains-mono
    pinentry-qt
  ];

}
