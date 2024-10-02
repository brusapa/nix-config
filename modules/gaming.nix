{ inputs, lib, config, pkgs, ... }:

{

  environment.systemPackages = with pkgs; [
    xboxdrv # X-Box controller
    mangohud # FPS counter
    lutris
    bottles
  ];

  programs.gamemode.enable = true;

  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };

  # Modify the game launcher to use the following options
  # gamemoderun %command%
  # mangohud %command%
  # gamescope %command%
}