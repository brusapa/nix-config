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
    #./kicad.nix # Long build time
    ./obs-studio.nix
  ];

  home.packages = with pkgs; [
    spotify
    jetbrains-mono
    bitwarden-desktop
    veracrypt
    obsidian
    pinentry-qt
    orca-slicer
    cryptomator
    gimp
    moonlight-qt
  ];

}
