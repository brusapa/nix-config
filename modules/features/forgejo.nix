{ den, ...}:
{
  den.aspects.forgejo = {
    includes = [
      den.aspects.reverse-proxy
    ];

    nixos = { config, ...}: {

      sops =  {
        secrets = {
          "forgejo/database-password" = { };
        };
      };

      users.users.${config.services.forgejo.user}.extraGroups = [ "ssh-login" ];

      services.forgejo = {
        enable = true;
        lfs.enable = true;
        database.passwordFile = config.sops.secrets."forgejo/database-password".path;
        settings = {
          server = {
            DOMAIN = "git.${config.reverseProxy.baseDomain}";
            HTTP_PORT = 7862;
            ROOT_URL = "https://git.${config.reverseProxy.baseDomain}";
          };
          repository = {
            DEFAULT_PRIVATE = "private";
          };
        };
      };

      reverseProxy.hosts.git.httpPort = config.services.forgejo.settings.server.HTTP_PORT;
    };
  };
}