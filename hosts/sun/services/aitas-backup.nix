{ config, ... }:
{

  # Import the needed secrets
  sops.secrets = {
    nas-aitas-backup-hashed-password = {
      sopsFile = ../secrets.yaml;
      neededForUsers = true;
    };
  };

  users.users.nas-aitas-backup = {
    isNormalUser = true;
    description = "User for backing up aitas NAS";
    hashedPasswordFile = config.sops.secrets.nas-aitas-backup-hashed-password.path;
    home = "/home/nas-aitas-backup";
    createHome = true;
    extraGroups = [
      "ssh-login"
    ];
  };

}
