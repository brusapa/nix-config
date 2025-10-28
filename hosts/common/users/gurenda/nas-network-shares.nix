{ config, ... }:

{

  imports = [
    ../../../../modules/samba-client.nix
  ];

  sops.secrets.gurenda-smb-password = {};

  sops.templates."gurenda-cifs-credentials" = {
    content = ''
      username=gurenda
      password=${config.sops.placeholder.gurenda-smb-password}
    '';
    owner = "gurenda";
  };

  # SMB NAS Home Gurenda
  fileSystems."/home/gurenda/NAS/home" = {
    device = "//sun.brusapa.com/gurenda";
    fsType = "cifs";
    options = let
      # this line prevents hanging on network split
      automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";

    in ["${automount_opts},credentials=${config.sops.templates."gurenda-cifs-credentials".path},uid=${toString config.users.users.gurenda.uid},gid=${toString config.users.groups.users.gid}"];
  };

}
