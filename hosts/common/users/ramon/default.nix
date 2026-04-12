{
  config,
  pkgs,
  ...
}: let
  username = "ramon";
  ifGroupExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
  smbSecretPath = config.sops.secrets."${username}-smb-password".path;
in {
  sops.secrets."${username}-hashed-password".neededForUsers = true;

  users.users.${username} = {
    isNormalUser = true;
    description = "Ramon";
    hashedPasswordFile = config.sops.secrets."${username}-hashed-password".path;
    uid = 1002;
    home = "/home/${username}";
    createHome = true;
    extraGroups = ifGroupExist [
      "users"
      "ssh-login"
    ];
    openssh.authorizedKeys.keyFiles = [
      ./ssh-key.pub
    ];
  };

  # Samba Password
  # Import the needed secrets
  sops = {
    secrets = {
      "ramon-smb-password" = {
        sopsFile = ../../secrets.yaml;
      };
    };
  };

  system.activationScripts = {
    # The "init_smbpasswd" script name is arbitrary, but a useful label for tracking
    # failed scripts in the build output. An absolute path to smbpasswd is necessary
    # as it is not in $PATH in the activation script's environment. The password
    # is repeated twice with newline characters as smbpasswd requires a password
    # confirmation even in non-interactive mode where input is piped in through stdin. 
    "init_${username}_smbpasswd".text = ''
      /run/current-system/sw/bin/printf "$(/run/current-system/sw/bin/cat ${smbSecretPath})\n$(/run/current-system/sw/bin/cat ${smbSecretPath})\n" | ${pkgs.samba}/bin/smbpasswd -sa ${username}
    '';
  };
}
