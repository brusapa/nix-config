{ den, ... }:
{
  den.aspects.gurenda = {
    includes = [
      den.batteries.define-user
      den.aspects.user-main-group
      den.aspects.user-password
      den.aspects.samba-user

      ({ host, ... }: if host.role == "workstation" then den.aspects.gurenda.desktop else { })
    ];

    user =
      { config, ... }:
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
      };

    homeManager = {
      home = {
        language.base = "es_ES.UTF-8";
      };
    };
  };
}
