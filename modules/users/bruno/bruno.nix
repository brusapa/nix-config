{
  inputs,
  self,
  ...
}:

let
  username = "bruno";
in
{
  flake.modules.nixos."${username}" =
    {
      pkgs,
      config,
      ...
    }: let
        ifGroupExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
    in {
      sops.secrets.bruno-hashed-password.neededForUsers = true;

      users.users."${username}" = {
        isNormalUser = true;
        description = "Bruno";
        hashedPasswordFile = "changeme";
        uid = 1000;
        extraGroups = ifGroupExist [
          "users"
          "docker"
          "downloads"
          "dialout"
          "gamemode"
          "immich"
          "input"
          "libvirtd"
          "lp"
          "multimedia"
          "networkmanager"
          "podman"
          "scanner"
          "ssh-login"
          "vboxusers"
          "whale-frigate-sync"
          "wheel"
        ];
        openssh.authorizedKeys.keyFiles = [
          ../../../../home/bruno/ssh-gpg.pub
        ];
        home = "/home/${username}";
        createHome = true;
        shell = pkgs.fish;
      };
      nix.settings.trusted-users = ["${username}"];
    };

  flake.modules.homeManager."${username}" = {
    home = {
      username = "${username}";
      homeDirectory = "/home/${username}";
      language = let 
        nativeLocale = "es_ES.UTF-8";
      in {
        base = "en_US.UTF-8";
        address = nativeLocale;
        measurement = nativeLocale;
        monetary = nativeLocale;
        name = nativeLocale;
        paper = nativeLocale;
        telephone = nativeLocale;
        time = nativeLocale;
      };
    };

    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      matchBlocks  = {
        "sun" = {
          hostname = "sun.brusapa.com";
          user = "bruno";
          forwardAgent = true;
          remoteForwards = [
            {
              bind.address = ''/run/user/1000/gnupg/S.gpg-agent'';
              host.address = ''/run/user/1000/gnupg/S.gpg-agent.extra'';
            }
          ];
          extraOptions.StreamLocalBindUnlink = "yes";
        };
        "pluto" = {
          hostname = "pluto.brusapa.com";
          user = "bruno";
          forwardAgent = true;
          remoteForwards = [
            {
              bind.address = ''/run/user/1000/gnupg/S.gpg-agent'';
              host.address = ''/run/user/1000/gnupg/S.gpg-agent.extra'';
            }
          ];
          extraOptions.StreamLocalBindUnlink = "yes";
        };
        "mars" = {
          hostname = "mars.brusapa.com";
          user = "bruno";
          forwardAgent = true;
          remoteForwards = [
            {
              bind.address = ''/run/user/1000/gnupg/S.gpg-agent'';
              host.address = ''/run/user/1000/gnupg/S.gpg-agent.extra'';
            }
          ];
          extraOptions.StreamLocalBindUnlink = "yes";
        };
      };
    };
    
  };
}