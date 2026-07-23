{ den, ... }:
{
  den.aspects.couchdb = {
    includes = [
      den.aspects.reverse-proxy
    ];

    nixos = { config, ... }: {
      # Import the needed secrets
      sops = {
        secrets = {
          "couchdb/admin-password" = { };
        };
        templates."couchdb-admins.ini" = {
          owner = config.services.couchdb.user;
          group = config.services.couchdb.group;
          content = ''
            [admins]
            admin = ${config.sops.placeholder."couchdb/admin-password"}
          '';
        };
      };


      services.couchdb = {
        enable = true;
        extraConfigFiles = [
          config.sops.templates."couchdb-admins.ini".path
        ];
      };

      reverseProxy.hosts.couchdb.httpPort = config.services.couchdb.port;
    };
  };
}