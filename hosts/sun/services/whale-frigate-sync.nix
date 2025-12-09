{ config, pkgs, lib, ... }:
let
  local-path = "/mnt/satassd/whale-frigate-sync";
  local-user = "whale-frigate-sync";
  remote-host = "sonabia.brusapa.com";
  remote-user = "sun-frigate-sync";
  remote-path = "/mnt/hdd1/frigate_storage/recordings";
in {
  # Import the needed secrets
  sops.secrets = {
    "whale-frigate-backup/ssh-private-key" = {
      sopsFile = ../secrets.yaml;
      owner = local-user;
      mode = "0600";
    };
  };

  users.groups.${local-user} = {};
  users.users.${local-user} = {
    isSystemUser = true;
    group = local-user;
    shell = pkgs.bashInteractive;
    description = "Backup user for whale frigate recordings";
  };

  # Create backup directory if does not exist
  systemd.tmpfiles.rules = [
    "d ${local-path} 0750 ${local-user} ${local-user} -"
  ];

  systemd.services."whale-frigate-sync" = {
    description = "Pull whale frigate recordings via rsync";
    serviceConfig = {
      Type = "oneshot";
      User = local-user;
      Group = local-user;
    };

    path = [ pkgs.rsync pkgs.openssh ];

    script = ''
      rsync -az --delete --bwlimit=10000 \
        -e "ssh -i ${config.sops.secrets."whale-frigate-backup/ssh-private-key".path} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" \
        ${remote-user}@${remote-host}:${remote-path} \
        ${local-path}
    '';
  };

  systemd.timers."whale-frigate-sync" = {
    description = "Run whale frigate rsync backup periodically";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "5m";
      OnUnitActiveSec = "1m";
      Unit = "whale-frigate-sync.service";
    };
  };
}
