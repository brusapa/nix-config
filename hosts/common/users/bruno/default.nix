{
  lib,
  config,
  pkgs,
  ...
}: let
  ifGroupExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in {
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.groups.users.gid = 100;

  users.users.bruno = {
    isNormalUser = true;
    description = "Bruno";
    uid = 1000;
    extraGroups = ifGroupExist [
      "docker"
      "gamemode"
      "libvirtd"
      "lp"
      "networkmanager"
      "scanner"
      "vboxusers"
      "wheel"
    ];
    openssh.authorizedKeys.keys = lib.splitString "\n" (builtins.readFile ../../../../home/bruno/ssh.pub);
    home = "/home/bruno";
    createHome = true;
  };

  nix.settings.trusted-users = ["bruno"];
}
