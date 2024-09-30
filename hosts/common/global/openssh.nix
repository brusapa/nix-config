{ outputs, lib, config, ... }:

{
  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      AllowUsers = [ "bruno" ];
    };
    extraConfig = ''
      AllowAgentForwarding yes
      StreamLocalBindUnlink yes
    '';
  };

  # Allow sudo through ssh agent
  security.pam.sshAgentAuth.enable = true;
  security.pam.services.sudo.sshAgentAuth = true;
}