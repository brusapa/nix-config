{
  den.aspects.openssh-server.nixos = { config, ...}:
  {

    # Create the ssh-login group
    users.groups.ssh-login = { };

    # Enable the OpenSSH daemon.
    services.openssh = {
      enable = true;
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
  };
}