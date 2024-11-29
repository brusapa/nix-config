{ pkgs, ... }:

{

  environment.systemPackages = with pkgs; [
    alsa-scarlett-gui
  ];

}