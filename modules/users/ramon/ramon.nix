{ den, ... }:
{
  den.aspects.ramon = {
    includes = [
      den.batteries.define-user
      den.aspects.user-main-group
      den.aspects.user-password
      den.aspects.samba-user
    ];

    user =
      { config, ... }:
      let
        ifGroupExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
      in
      {
        uid = 1002;
        extraGroups = ifGroupExist [
          "users"
        ];
      };

    homeManager = {
      home = {
        language.base = "es_ES.UTF-8";
      };
    };
  };
}
