{ inputs, lib, config, pkgs, ... }:

{

  imports = [
    ../../../../modules/samba.nix
  ];

  sops.secrets.gurenda-smb-password = {
    file = "../../secrets.yaml";
  };

  sops.templates."gurenda-smb-credentials" = {
    content = ''
      username=gurenda;
      password=${sops.secrets.gurenda-smb-password};
    '';
    owner = "gurenda";
  };

  # SMB NAS Home Gurenda
  fileSystems."${config.users.users.gurenda.home}/NAS/home" = {
    device = "//nas.brusapa.com/home";
    fsType = "cifs";
    options = let
      # this line prevents hanging on network split
      automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";

    in ["${automount_opts},credentials=${config.sops.templates."gurenda-smb-credentials".path},uid=${toString config.users.users.gurenda.uid},gid=${toString config.users.groups.users.gid}"];
  };

  # SMB NAS Casa Gurenda
  fileSystems."${config.users.users.gurenda.home}/NAS/casa" = {
    device = "//nas.brusapa.com/casa";
    fsType = "cifs";
    options = let
      # this line prevents hanging on network split
      automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";

    in ["${automount_opts},credentials=${config.sops.templates."gurenda-smb-credentials".path},uid=${toString config.users.users.gurenda.uid},gid=${toString config.users.groups.users.gid}"];
  };

}