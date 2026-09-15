{ den, ... }:
{
  den.aspects.sun = {
    includes = [
      den.aspects.wordpress
    ];

    nixos =
      { config, ... }:
      {
        # Import the needed secrets
        sops = {
          secrets = {
            "serafinylapelota/database-password" = { };
          };
          templates."serafinylapelota-secrets.env" = {
            content = ''
              MARIADB_PASSWORD=${config.sops.placeholder."serafinylapelota/database-password"}
              WORDPRESS_DB_PASSWORD=${config.sops.placeholder."serafinylapelota/database-password"}
            '';
          };
        };

        wordpress.serafinylapelota = {
          port = 7651;
          subdomain = "serafinylapelota";
          dbPasswordFile = config.sops.templates."serafinylapelota-secrets.env".path;
        };
      };
  };
}
