{ lib, pkgs, ... }:

{

  imports = [
    ./firefox.nix
    ./remmina.nix
    ./virt-manager.nix
    ./vscode.nix
    ./default-applications.nix
    ./changeResolutionDesktopEntries.nix
    ./development
    ./kicad.nix
  ];

  home.packages = with pkgs; [
    spotify
    jetbrains-mono
    bitwarden-desktop
    veracrypt
    cryptomator
    microsoft-edge
    obsidian
    pinentry-qt
    orca-slicer
  ];

}
