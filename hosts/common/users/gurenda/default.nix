{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: let
  ifGroupExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in {
  users.users.gurenda = {
    isNormalUser = true;
    description = "Gurenda";
    home = "/home/gurenda";
    createHome = true;
    extraGroups = ifGroupExist [
      "lp"
      "scanner"
    ];
  };
}
