{
  den.aspects.user-main-group = { user, ... }: {

    user = {
      group = user.userName;
    };

    provides.to-hosts.nixos = { config, ... }: {
      users.groups.${user.userName} = {
        gid = config.users.users.${user.userName}.uid;
      };
    };
  };
}
