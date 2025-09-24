{ pkgs, inputs, ... }:

{

  imports = [
    inputs.nix-flatpak.homeManagerModules.nix-flatpak
    ./firefox.nix
    ../../../../common/autofirma.nix
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
    orca-slicer
    cryptomator
    gimp
    moonlight-qt
    ente-auth
    freecad-wayland
    scrcpy
  ];

  services.flatpak.packages = [
    "com.bambulab.BambuStudio"
  ];
}
