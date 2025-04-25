{ lib, pkgs, ... }:

{

  programs.plasma = {
    enable = true;

    fonts = {
      general = {
        family = "JetBrains Mono";
        pointSize = 10;
      };
      fixedWidth = {
        family = "JetBrains Mono";
        pointSize = 10;
      };
      menu = {
        family = "JetBrains Mono";
        pointSize = 10;
      };
      small = {
        family = "JetBrains Mono";
        pointSize = 8;
      };
      toolbar = {
        family = "JetBrains Mono";
        pointSize = 10;
      };
      windowTitle = {
        family = "JetBrains Mono";
        pointSize = 10;
      };
    };

    hotkeys.commands."launch-dolphin" = {
      name = "Launch Dolphin";
      key = "Ctrl+Alt+E";
      command = "dolphin";
    };

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
                "applications:firefox.desktop"
                "applications:code.desktop"
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
          action = "sleep";
          idleTimeout = 900; # In seconds (15 minutes)
        };
        turnOffDisplay = {
          idleTimeout = 300; # In seconds (5 minutes)
          idleTimeoutWhenLocked = "immediately";
        };
      };
    };
  };

  programs.konsole = {
    enable = true;
    defaultProfile = "bruno";
    extraConfig = {
      KonsoleWindow = {
        RememberWindowSize = false;
      };
    };
    profiles.default = {
      name = "bruno";
      colorScheme = "BlackOnWhite";
      font = {
        name = "JetBrainsMono  Nerd Font";
        size = 10;
      };
      extraConfig = {
        General = {
          TerminalColumns = 120;
          TerminalRows = 40;
        };
      };
    };
  };

}
