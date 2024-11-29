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

  # Allow sudo through ssh agent (RSSH)
  security.pam = {
    rssh.enable = true;
    services.sudo.rssh = true;
  };
}
