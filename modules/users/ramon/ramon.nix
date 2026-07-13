{ den, ... }:
{
  den.aspects.ramon = {
    includes = [
      den.batteries.define-user
      den.aspects.sops
    ];

    user =
      { config, ... }:
      let
        ifGroupExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
      in
      {
        uid = 1002;
        extraGroups = ifGroupExist [
          "users"
        ];
        hashedPasswordFile = config.sops.secrets.ramon-hashed-password.path;
      };

    homeManager = { pkgs, ... }: {
      home = {
        language = {
          base = "es_ES.UTF-8";
          address = "es_ES.UTF-8";
          measurement = "es_ES.UTF-8";
          monetary = "es_ES.UTF-8";
          name = "es_ES.UTF-8";
          paper = "es_ES.UTF-8";
          telephone = "es_ES.UTF-8";
          time = "es_ES.UTF-8";
        };
      };
    };

    provides.to-hosts.nixos =
      {
        pkgs,
        config,
        user,
        ...
      }:
      {
        sops.secrets = {
          ramon-hashed-password = {
            neededForUsers = true;
            sopsFile = ../secrets.yaml;
          };
          "ramon-smb-password" = {
            sopsFile = ../secrets.yaml;
          };
        };

        system.activationScripts =
          let
            smbSecretPath = config.sops.secrets."${user.userName}-smb-password".path;
          in
          {
            # The "init_smbpasswd" script name is arbitrary, but a useful label for tracking
            # failed scripts in the build output. An absolute path to smbpasswd is necessary
            # as it is not in $PATH in the activation script's environment. The password
            # is repeated twice with newline characters as smbpasswd requires a password
            # confirmation even in non-interactive mode where input is piped in through stdin.
            "init_${user.userName}_smbpasswd".text = ''
              /run/current-system/sw/bin/printf "$(/run/current-system/sw/bin/cat ${smbSecretPath})\n$(/run/current-system/sw/bin/cat ${smbSecretPath})\n" | ${pkgs.samba}/bin/smbpasswd -sa ${user.userName}
            '';
          };
      };
  };
}
