{
  config,
  pkgs,
  ...
}: let
  ifGroupExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in {
  sops.secrets.bruno-hashed-password.neededForUsers = true;

  users.users.bruno = {
    isNormalUser = true;
    description = "Bruno";
    hashedPasswordFile = config.sops.secrets.bruno-hashed-password.path;
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
      "wheel"
    ];
    openssh.authorizedKeys.keyFiles = [
      ../../../../home/bruno/ssh-gpg.pub
    ];
    home = "/home/bruno";
    createHome = true;
    shell = pkgs.fish;
  };

  nix.settings.trusted-users = ["bruno"];
}
