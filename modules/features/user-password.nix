{ den, ... }:
{
  den.aspects.user-password = { user, ... }: {

    includes = [
      den.aspects.sops
    ];

    user = { config, ... }: {
      hashedPasswordFile = config.sops.secrets."${user.userName}-hashed-password".path;
    };

    provides.to-hosts.nixos = {
      sops.secrets."${user.userName}-hashed-password" = {
        neededForUsers = true;
        sopsFile = ../users/secrets.yaml;
      };
    };
  };
}
