{ den, ... }:
{
  den.aspects.bruno = {
    includes = [
      den.batteries.define-user
      den.batteries.primary-user
      (den.batteries.user-shell "fish")

      den.aspects.sops

      ({ host, ... }: if host.role == "workstation" then den.aspects.bruno.desktop else { })
    ];

    user =
      { config, ... }:
      let
        ifGroupExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
      in
      {
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
          "romm"
          "scanner"
          "ssh-login"
          "uinput"
          "vboxusers"
          "whale-frigate-sync"
          "wheel"
        ];
        hashedPasswordFile = config.sops.secrets.bruno-hashed-password.path;
        openssh.authorizedKeys.keyFiles = [
          ./ssh-gpg.pub
        ];
      };

    homeManager = { pkgs, ... }: {
      home = {
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
        packages = [ pkgs.htop ];
      };
    };

    provides.to-hosts.nixos = { ... }: {
      nix.settings.trusted-users = [ "bruno" ];
      sops.secrets.bruno-hashed-password = {
        neededForUsers = true;
        sopsFile = ../secrets.yaml;
      };
    };
  };
}
