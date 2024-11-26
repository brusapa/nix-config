{...}: {
  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      AllowUsers = ["bruno"];
      AllowTcpForwarding = true;
      AllowAgentForwarding = true;
      StreamLocalBindUnlink = true;
    };
  };

  programs.ssh.startAgent = true;

  # Allow sudo through ssh agent
  security.pam = {
    sshAgentAuth = {
      enable = true;
      authorizedKeysFiles = ["/etc/ssh/authorized_keys.d/%u"];
    };
    services.sudo.sshAgentAuth = true;
  };
}
