{ lib, pkgs, ... }:

{
  home = {
    packages = with pkgs; [
      spotify
      bitwarden-desktop
      google-chrome
    ];

    language.base = "es_ES.UTF-8";

    # This needs to actually be set to your username
    username = "gurenda";
    homeDirectory = "/home/gurenda";

    # You do not need to change this if you're reading this in the future.
    # Don't ever change this after the first build.  Don't ask questions.
    stateVersion = "24.05";
  };

  programs.plasma = {
    enable = true;

    input.keyboard = {
      layouts = [ 
        {
          layout = "es";
        }        
      ];
      numlockOnStartup = "on";
    };

    panels = [
      # Windows-like panel at the bottom
      {
        location = "bottom";
        widgets = [

          # Start menu
          {
            kickoff = {
              sortAlphabetically = true;
              icon = "nix-snowflake-white";
            };
          }

          # Task manager pinned apps
          {
            iconTasks = {
              launchers = [
                "applications:org.kde.dolphin.desktop"
              ];
            };
          }

          # Separator
          "org.kde.plasma.marginsseparator"

          # System tray
          {
            systemTray.items = {
              shown = [
                "org.kde.plasma.networkmanagement"
                "org.kde.plasma.volume"
              ];
              hidden = [
                "org.kde.plasma.bluetooth"
              ];
            };
          }

          # Clock
          {
            digitalClock = {
              calendar.firstDayOfWeek = "monday";
              time.format = "24h";
            };
          }
        ];
      }
    ];

    powerdevil = {
      AC = {
        powerButtonAction = "nothing";
        autoSuspend = {
          action = "nothing";
        };
        turnOffDisplay = {
          idleTimeout = 900; # In seconds (15 minutes)
          idleTimeoutWhenLocked = "immediately";
        };
      };
    };
  };
}