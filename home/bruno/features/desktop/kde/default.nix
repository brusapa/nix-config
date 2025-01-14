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
    (catppuccin-kde.override {
      flavour = [ "latte" ];
      accents = [
        "blue"
        "teal"
        "lavender"
      ];
    })
    catppuccin-kde
  ];

}
