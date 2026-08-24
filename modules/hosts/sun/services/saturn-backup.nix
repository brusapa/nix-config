{ den, ... }:
{
  den.aspects.sun = {

    nixos = {
      # User to backup saturn related files
      users.groups.saturn-backup = { };
      users.users.saturn-backup = {
        group = "saturn-backup";
        extraGroups = [
          "ssh-login"
        ];
        isSystemUser = true;
        shell = pkgs.bashInteractive;
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHbA5ZXARP8UYRJNHyc1IllAugmmzhkXjfOqb7075/NE saturn-backup"
        ];
      };

      # Directory create directory to store backups
      systemd.tmpfiles.rules = [
        "d /zstorage/internal-backups/saturn 0755 saturn-backup saturn-backup -"
      ];

    };
  };
}
