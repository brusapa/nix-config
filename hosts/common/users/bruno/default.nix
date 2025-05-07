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
      "users"
      "docker"
      "dialout"
      "gamemode"
      "input"
      "libvirtd"
      "lp"
      "networkmanager"
      "scanner"
      "vboxusers"
      "wheel"
    ];
    openssh.authorizedKeys.keyFiles = [
      ../../../../home/bruno/ssh.pub 
      ../../../../home/bruno/ssh-gpg.pub
    ];
    home = "/home/bruno";
    createHome = true;
    shell = pkgs.fish;
  };

  nix.settings.trusted-users = ["bruno"];
}
