{ den, ... }:
{
  den.aspects.gurenda = {
    includes = [
      den.batteries.define-user
      den.aspects.sops

      ({ host, ... }: if host.role == "workstation" then den.aspects.gurenda.desktop else { })
    ];

    user = { config, ... }:
    let
      ifGroupExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
    in 
    {
      uid = 1001;
      extraGroups = ifGroupExist [
        "users"
        "lp"
        "scanner"
      ];
      hashedPasswordFile = config.sops.secrets.gurenda-hashed-password.path;
    };

    homeManager = { pkgs, ... }: {
      home = {
        language = {
          base = "es_ES.UTF-8";
          address = "es_ES.UTF-8";
          measurement = "es_ES.UTF-8";
          monetary = "es_ES.UTF-8";
          name = "es_ES.UTF-8";
          paper = "es_ES.UTF-8";
          telephone = "es_ES.UTF-8";
          time = "es_ES.UTF-8";
        };
      };
    };

    provides.to-hosts.nixos = { ... }: { 
      sops.secrets.gurenda-hashed-password = {
        neededForUsers = true;
        sopsFile = ../secrets.yaml;
      };
    };
  };
}