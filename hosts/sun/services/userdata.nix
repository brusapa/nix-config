{ ... }:
{

  # Import the needed secrets
  sops = {
    secrets = {
      backup-password = {
        sopsFile = ../secrets.yaml;
      };
    };
  };

  # Daily internal backup
  services.restic.backups.usersInternalBackup = {
    repository = "/mnt/internalBackup/users";
    passwordFile = config.sops.secrets.backup-password.path;
    initialize = true;

    paths = [ "/zstorage/users" ];

    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
    };

    pruneOpts = [
      "--keep-daily 7"
      "--keep-monthly 12"
    ];
  };

}