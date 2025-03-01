{ lib, pkgs, ... }:

{

  imports = [
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
