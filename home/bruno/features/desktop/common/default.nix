{ pkgs, ... }:

{

  imports = [
    ./firefox.nix
    ./autofirma.nix
    ./chromium.nix
    ./remmina.nix
    ./virt-manager.nix
    ./vscode.nix
    ./default-applications.nix
    ./changeResolutionDesktopEntries.nix
    ./development
    ./kicad.nix
    ./obs-studio.nix
  ];

  home.packages = with pkgs; [
    spotify
    jetbrains-mono
    bitwarden-desktop
    veracrypt
    microsoft-edge
    obsidian
    pinentry-qt
    orca-slicer
    cryptomator
    gimp
    moonlight-qt
  ];

}
