{ lib, pkgs, ... }:

{
  imports = [
    ../common/virt-manager.nix
    ../features/firefox.nix
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
      microsoft-edge
      obsidian
      pinentry-qt
      orca-slicer
    ];

    language = {
      base = "en_US.UTF-8";
      address = "es_ES.UTF-8";
      measurement = "es_ES.UTF-8";
      monetary = "es_ES.UTF-8";
      name = "es_ES.UTF-8";
      paper = "es_ES.UTF-8";
      telephone = "es_ES.UTF-8";
      time = "es_ES.UTF-8";
    };

    # This needs to actually be set to your username
    username = "bruno";
    homeDirectory = "/home/bruno";

    # You do not need to change this if you're reading this in the future.
    # Don't ever change this after the first build.  Don't ask questions.
    stateVersion = "24.05";
  };

  xdg.mimeApps = 
  {
    enable = true;
    defaultApplications = {
      "x-scheme-handler/http" = [ "firefox.desktop" ];
      "x-scheme-handler/https" = [ "firefox.desktop" ];
      "application/json" = [ "code.desktop" ];
      "application/pdf" = [ "okularApplication_pdf.desktop" ];
      "application/x-docbook+xml" = [ "code.desktop" ];
      "application/x-yaml" = [ "code.desktop" ];
      "text/markdown" = [ "code.desktop" ];
      "text/plain" = [ "code.desktop" ];
      "text/x-cmake" = [ "code.desktop" ];
    };
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

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    extraConfig = ''
      set number
    '';
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
}
