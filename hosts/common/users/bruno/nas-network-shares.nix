{ config, ... }:

{

  imports = [
    ../../../../modules/samba.nix
  ];

  sops.secrets.bruno-smb-password = { };

  sops.templates."bruno-cifs-credentials" = {
    content = ''
      username=bruno
      password=${config.sops.placeholder.bruno-smb-password}
    '';
    owner = "bruno";
  };

  # SMB NAS Home Bruno
  fileSystems."/home/bruno/NAS/home" = {
    device = "//sun.brusapa.com/bruno";
    fsType = "cifs";
    options = let
      # this line prevents hanging on network split
      automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";

    in ["${automount_opts},credentials=${config.sops.templates."bruno-cifs-credentials".path},uid=${toString config.users.users.bruno.uid},gid=${toString config.users.groups.users.gid}"];
  };

  # SMB NAS Casa Bruno
  fileSystems."/home/bruno/NAS/casa" = {
    device = "//sun.brusapa.com/casa";
    fsType = "cifs";
    options = let
      # this line prevents hanging on network split
      automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";

    in ["${automount_opts},credentials=${config.sops.templates."bruno-cifs-credentials".path},uid=${toString config.users.users.bruno.uid},gid=${toString config.users.groups.users.gid}"];
  };

}
