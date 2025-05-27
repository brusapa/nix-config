{ inputs, lib, config, pkgs, ... }:

{

  environment.systemPackages = with pkgs; [
    mangohud # FPS counter
    lutris
    bottles
  ];

  programs.gamemode.enable = true;
  users.groups.gamemode.members = [ "bruno" ];

  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };

  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
    package = pkgs.steam.override { # Fix gamescope not working on steam due to missing libraries https://github.com/NixOS/nixpkgs/issues/214275
      extraPkgs = pkgs:
        with pkgs; [
          xorg.libXcursor
          xorg.libXi
          xorg.libXinerama
          xorg.libXScrnSaver
          libpng
          libpulseaudio
          libvorbis
          stdenv.cc.cc.lib
          libkrb5
          keyutils
        ];
    };
  };

  # Modify the game launcher to use the following options
  # gamescope --force-grab-cursor -W 2560 -H 1440 -r 120 -f -e gamemoderun %command%
  # env LD_PRELOAD="" gamescope --force-grab-cursor -W 2560 -H 1440 -r 120 -f -e %command%
  # gamemoderun %command%
  # mangohud %command%
  # gamescope %command%
}