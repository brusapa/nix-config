{ inputs, lib, config, pkgs, ... }:

{

  imports = [
    ../../../../modules/samba.nix
  ];

  # SMB NAS Home Bruno
  fileSystems."/home/bruno/NAS/home" = {
    device = "//nas.rex-eagle.ts.net/home";
    fsType = "cifs";
    options = let
      # this line prevents hanging on network split
      automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";

    in ["${automount_opts},credentials=${config.users.users.bruno.home}/.smb-secrets,uid=${toString config.users.users.bruno.uid},gid=${toString config.users.groups.users.gid}"];
  };

  # SMB NAS Casa Bruno
  fileSystems."/home/bruno/NAS/casa" = {
    device = "//nas.rex-eagle.ts.net/casa";
    fsType = "cifs";
    options = let
      # this line prevents hanging on network split
      automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";

    in ["${automount_opts},credentials=${config.users.users.bruno.home}/.smb-secrets,uid=${toString config.users.users.bruno.uid},gid=${toString config.users.groups.users.gid}"];
  };

}