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

  # Sunshine
  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;  
    # settings = {
    #   global_prep_cmd = "[{\"do\":\"sh -c \"${pkgs.kdePackages.libkscreen}/bin/kscreen-doctor output.DP-3.mode.\${SUNSHINE_CLIENT_WIDTH}x\${SUNSHINE_CLIENT_HEIGHT}@\${SUNSHINE_CLIENT_FPS}\"\",\"undo\":\"${pkgs.kdePackages.libkscreen}/bin/kscreen-doctor output.DP-3.mode.5120x1440@240\"}]";
    # };
    # applications = {
    #   env = {
    #     PATH = "$(PATH):$(HOME)/.local/bin";
    #   };
    #   apps = [
    #     {
    #       name = "Desktop";
    #       image-path = "desktop.png";
    #     }
    #     {
    #       name = "Low Res Desktop";
    #       image-path = "desktop.png";
    #       prep-cmd = [
    #         {
    #           do = "${pkgs.kdePackages.libkscreen}/bin/kscreen-doctor output.DP-3.mode.1920x1080";
    #           undo = "${pkgs.kdePackages.libkscreen}/bin/kscreen-doctor output.DP-3.mode.5120x1440@240";
    #         }
    #       ];
    #     }
    #     {
    #       name = "Steam Big Picture";
    #       detached = [
    #         "${pkgs.util-linux}/bin/setsid ${pkgs.steam}/bin/steam steam://open/bigpicture"
    #       ];
    #       image-path = "steam.png";
    #     }
    #   ];
    # };
  };

}