{ inputs, ... }:
{
  den.aspects.gurenda.desktop = {
    nixos = {
      # Profile photo for plasma login
      systemd.tmpfiles.rules = [
        "L+ /var/lib/AccountsService/icons/gurenda - - - - ${./profile-photo.png}"
      ];
    };

    homeManager =
      { pkgs, config, ... }:
      {
        imports = [
          inputs.plasma-manager.homeModules.plasma-manager
        ];

        home = {
          packages = with pkgs; [
            spotify
            # bitwarden-desktop # Temporary disabled until electron 39 not used
            google-chrome
          ];

          language.base = "es_ES.UTF-8";
        };

        programs.firefox = {
          enable = true;
          configPath = "${config.xdg.configHome}/mozilla/firefox";
          profiles.default = {
            id = 0;
            search = {
              force = true;
              default = "google";
              privateDefault = "google";
              order = ["google"];
            };
          };
        };

        # Copy profile photo
        home.file.profile-photo = {
          enable = true;
          source = ./profile-photo.png;
          target = ".face.icon";
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
      };
  };
}
