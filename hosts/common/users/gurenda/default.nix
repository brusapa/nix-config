{
  config,
  ...
}: let
  ifGroupExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in {
  sops.secrets.gurenda-hashed-password.neededForUsers = true;

  users.users.gurenda = {
    isNormalUser = true;
    description = "Gurenda";
    hashedPasswordFile = config.sops.secrets.gurenda-hashed-password.path;
    uid = 1001;
    home = "/home/gurenda";
    createHome = true;
    extraGroups = ifGroupExist [
      "users"
      "lp"
      "scanner"
    ];
  };
}
