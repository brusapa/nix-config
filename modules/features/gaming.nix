{
  den.aspects.gaming = {
    nixos = { pkgs, ... }:
    {

      environment.systemPackages = with pkgs; [
        mangohud # FPS counter
        goverlay # For customizing mangohud options
        lutris
        bottles
      ];

      programs.gamemode.enable = true;

      programs.gamescope.enable = true;

      programs.steam = {
        enable = true;
        remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
        localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
      };

      # Modify the game launcher to use the following options
      # gamescope --force-grab-cursor --mangoapp -W 2560 -H 1440 -r 120 -f -- %command%
    };
  };
}

