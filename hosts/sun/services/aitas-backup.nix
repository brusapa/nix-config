{ config, ... }:
let
  uid = 1002;
  gid = 963;
in {

  # Import the needed secrets
  sops.secrets = {
    nas-aitas-backup-hashed-password = {
      sopsFile = ../secrets.yaml;
      neededForUsers = true;
    };
  };

  users.groups.nas-aitas-backup.gid = gid;
  users.users.nas-aitas-backup = {
    uid = uid;
    group = "nas-aitas-backup";
    isNormalUser = true;
    description = "User for backing up aitas NAS";
    hashedPasswordFile = config.sops.secrets.nas-aitas-backup-hashed-password.path;
    home = "/home/nas-aitas-backup";
    createHome = true;
    extraGroups = [
      "ssh-login"
    ];
  };

  containers.aitas-backup = {
    autoStart = true;

    bindMounts = {
      user-hashed-password = {
        hostPath = config.sops.secrets.nas-aitas-backup-hashed-password.path;
        mountPoint = "/var/lib/secrets/user-hashed-password";
        isReadOnly = true;
      };
      backup-directory = {
        hostPath = "/zstorage/backups/nas-aitas";
        mountPoint = "/zstorage/backups/nas-aitas";
        isReadOnly = false;
      };
    };

    # Container’s own NixOS config:
    config = { pkgs, ... }: {
      system.stateVersion = "25.11";
      networking.hostName = "nas-aitas-backup";

      services.openssh = {
        enable = true;
        openFirewall = true;
        ports = [ 2222 ];
        settings = {
          PasswordAuthentication = true;
          PermitRootLogin = "no";
          AllowUsers = [ "nas-aitas-backup" ];
        };
      };

      environment.systemPackages = [
        pkgs.rsync
      ];

      users.groups.nas-aitas-backup.gid = gid;
      users = {
        mutableUsers = false;
        users = {
          nas-aitas-backup = {
            group = "nas-aitas-backup";
            uid = uid;
            isNormalUser = true;
            hashedPasswordFile = "/var/lib/secrets/user-hashed-password";
          };
          root.hashedPasswordFile = "/var/lib/secrets/user-hashed-password";
        };
      };
    };
  };
}
