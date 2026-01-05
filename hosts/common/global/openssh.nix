{ config, lib, ...}:
{

  # Create the ssh-login group
  users.groups.ssh-login = { };

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      AllowGroups = [ "ssh-login" ];
      AllowTcpForwarding = true;
      AllowAgentForwarding = true;
      StreamLocalBindUnlink = true;
    };
    hostKeys = [
      {
        comment = "${config.networking.hostName}";
        path = "/etc/ssh/ssh_host_ed25519_key";
        rounds = 100;
        type = "ed25519";
      }
    ];
  };

  programs.ssh.startAgent = false;

  # Allow sudo through ssh agent (RSSH)
  security.pam = {
    rssh = {
      enable = true;
      settings = {
        cue = true;
      };
    };
    services = {
      sudo.rssh = true; # Sudo over ssh
    };
  };
}
