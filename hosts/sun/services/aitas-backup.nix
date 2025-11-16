{ config, pkgs, lib, ... }:
{

  # Import the needed secrets
  sops.secrets = {
    nas-aitas-backup-hashed-password = {
      sopsFile = ../secrets.yaml;
      neededForUsers = true;
    };
    "aitas-backup/user-hashed-password" = {
      sopsFile = ../secrets.yaml;
    };
    "aitas-backup/tailscale-auth-key" = {
      sopsFile = ../secrets.yaml;
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

  # containers.aitas-backup = {
  #   autoStart = true;

  #   bindMounts = {
  #     user-hashed-password = {
  #       hostPath   = config.sops.secrets."aitas-backup/user-hashed-password".path;
  #       mountPoint = "/var/lib/secrets/user-hashed-password";
  #       isReadOnly = true;
  #     };
  #     tailscale-auth-key = {
  #       hostPath   = config.sops.secrets."aitas-backup/tailscale-auth-key".path;
  #       mountPoint = "/var/lib/secrets/tailscale-auth-key";
  #       isReadOnly = true;
  #     };
  #   };

  #   # Container gets its own veth, isolated from LAN
  #   privateNetwork = true;
  #   hostAddress  = "10.250.0.1";
  #   localAddress = "10.250.0.2";

  #   # Needed for Tailscale (userspace TUN + net caps)
  #   enableTun = true;
  #   additionalCapabilities = [ "CAP_NET_ADMIN" "CAP_NET_RAW" ];

  #   # Container’s own NixOS config:
  #   config = { config, pkgs, lib, ... }: {
  #     networking.hostName = "aitas-backup";

  #     services.openssh = {
  #       enable = true;
  #       openFirewall = true;
  #       settings = {
  #         PasswordAuthentication = true;
  #         KbdInteractiveAuthentication = true;
  #         PermitRootLogin = "no";
  #         AllowUsers = [ "aitas-backup" ];
  #       };
  #     };

  #     users.users.aitas-backup = {
  #       isNormalUser = true;
  #       hashedPasswordFile = "/var/lib/backup-secrets/backup.pass";
  #     };

  #     services.tailscale = {
  #       enable = true;
  #       hostname = "aitas-backup";
  #       useRoutingFeatures = "client";
  #       authKeyFile = "/var/lib/ts/authkey";  # provide with agenix/sops or tmpfiles (see below)
  #     };
  #   };
  # };

}
