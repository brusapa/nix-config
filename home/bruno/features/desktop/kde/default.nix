{ lib, pkgs, ... }:

{

  imports = [
    ../common
    ./plasma-settings.nix
  ];


  home.packages = with pkgs; [
    nerdfonts
    jetbrains-mono
    pinentry-qt
  ];

}
