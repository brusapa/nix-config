{ lib, pkgs, ... }:

{
  imports = [
    ../common/virt-manager.nix
  ];

  nixpkgs.config.allowUnfree = true;

  home = {
    packages = with pkgs; [
      spotify
      remmina
      jetbrains-mono
      bitwarden-desktop
      veracrypt
      cryptomator
      kleopatra
      microsoft-edge
      obsidian
      pinentry-qt
      orca-slicer
    ];

    # This needs to actually be set to your username
    username = "bruno";
    homeDirectory = "/home/bruno";

    # You do not need to change this if you're reading this in the future.
    # Don't ever change this after the first build.  Don't ask questions.
    stateVersion = "24.05";
  };

  programs.vscode = {
    enable = true;
  };

  programs.bash = {
    enable = true;
    shellAliases = {
      la = "ls -la";
    };
  };

  programs.gpg = {
    enable = true;
    publicKeys = [
      {
        source = ./GPGPublicKey.asc;
        trust = "ultimate";
      }
    ];
  };

  programs.git = {
    enable = true;
    userName = "Bruno Santamaria";
    lfs.enable = true;
    userEmail = "30648587+brusapa@users.noreply.github.com";
    signing = {
      signByDefault = true;
      key = "BD6743DAE6ABDF36";
    };
  };

  programs.lazygit = {
    enable = true;
  };

  programs.vim = {
    enable = true;
    defaultEditor = true;
    settings = {
      expandtab = true;
      tabstop = 2;
      shiftwidth = 2;
    };
  };

  programs.firefox = {
    enable = true;
    #profiles.default = {
    #  id = 0;
    #  settings = {
    #    "signon.rememberSignons" = false;
    #    "widget.use-xdg-desktop-portal.file-picker" = 1;
    #  };
    #};
  };

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
      layouts = [ "es" ];
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
          action = "nothing";
        };
        turnOffDisplay = {
          idleTimeout = 900; # In seconds (15 minutes)
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
        name = "JetBrains Mono";
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

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    enableExtraSocket = true;
    pinentryPackage = pkgs.pinentry-qt;
    defaultCacheTtl = 60; # https://github.com/drduh/config/blob/master/gpg-agent.conf
    maxCacheTtl = 120; # https://github.com/drduh/config/blob/master/gpg-agent.conf
  };

  services.kdeconnect = {
    enable = true;
  };
}
