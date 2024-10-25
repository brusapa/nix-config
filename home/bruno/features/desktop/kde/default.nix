{ lib, pkgs, ... }:

{

  imports = [
    ../common
    ./plasma-settings.nix
  ];


  home.packages = with pkgs; [
    jetbrains-mono
    pinentry-qt
  ];

}
