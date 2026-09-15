{ den, ... }:
{
  den.aspects.wordpress = {
    includes = [
      den.aspects.reverse-proxy
    ];
    nixos = { lib, config, pkgs, ... }:
      let
        inherit (lib) mkOption types;
        cfg = config.wordpress;
      in
      {
        options.wordpress = mkOption {
          type = types.attrsOf (
            types.submodule ({ name, ... }: {
              options = {
                port = mkOption {
                  type = types.port;
                  description = "Puerto del host (solo loopback)";
                };
                subdomain = mkOption {
                  type = types.str;
                  default = name;
                  description = "Subdominio usado por reverse-proxy.";
                };
                dbPasswordFile = mkOption {
                  type = types.path;
                  description = ''
                    Fichero de entorno (formato KEY=value) con MARIADB_PASSWORD
                    y WORDPRESS_DB_PASSWORD, normalmente vía sops-nix.
                  '';
                };
              };
            })
          );

          default = { };
          description = "Wordpress instances";
        };

        config = {
          # Asegura que los directorios de estado existen con permisos sanos
          # antes de que podman intente montarlos.
          systemd.tmpfiles.rules = lib.flatten (
            lib.mapAttrsToList (name: inst: [
              "d /var/lib/wordpress/${name}/html 0755 root root -"
              "d /var/lib/wordpress/${name}/db   0700 root root -"
            ]) cfg
          );

          # Red podman dedicada por instancia, para que la BD de una
          # instancia no sea alcanzable desde otra.
          systemd.services = lib.mapAttrs' (
            name: inst:
            lib.nameValuePair "podman-network-wp-${name}" {
              serviceConfig.Type = "oneshot";
              wantedBy = [ "multi-user.target" ];
              before = [ "podman-wp-${name}.service" "podman-wp-${name}-db.service" ];
              script = ''
                ${pkgs.podman}/bin/podman network exists wp-${name} || \
                  ${pkgs.podman}/bin/podman network create wp-${name}
              '';
            }
          ) cfg;

          virtualisation.oci-containers.containers =
            (lib.mapAttrs' (
              name: inst:
              lib.nameValuePair "wp-${name}-db" {
                image = "mariadb:11";
                volumes = [
                  "/var/lib/wordpress/${name}/db:/var/lib/mysql"
                ];
                environment = {
                  TZ = "Europe/Madrid";
                  MARIADB_DATABASE = "wordpress";
                  MARIADB_USER = "wordpress";
                  MARIADB_RANDOM_ROOT_PASSWORD = "yes";
                  MARIADB_CHARACTER_SET = "utf8mb4";
                  MARIADB_COLLATE = "utf8mb4_unicode_ci";
                };
                environmentFiles = [ inst.dbPasswordFile ];
                cmd = [
                  "--character-set-server=utf8mb4"
                  "--collation-server=utf8mb4_unicode_ci"
                ];
                extraOptions = [
                  "--network=wp-${name}"
                ];
              }
            ) cfg)
            //
            (lib.mapAttrs' (
              name: inst:
              let
                uploadsIni = pkgs.writeText "wp-${name}-uploads.ini" ''
                  upload_max_filesize = 5000M
                  post_max_size = 5000M
                  memory_limit = 5000M
                  max_execution_time = 600
                  max_input_time = 600
                '';
              in
              lib.nameValuePair "wp-${name}" {
                image = "wordpress:7.1.0-php8.5";
                dependsOn = [ "wp-${name}-db" ];
                volumes = [
                  "/var/lib/wordpress/${name}/html:/var/www/html"
                  "${uploadsIni}:/usr/local/etc/php/conf.d/zz-uploads.ini:ro"
                ];
                environment = {
                  TZ = "Europe/Madrid";
                  WORDPRESS_DB_HOST = "wp-${name}-db";
                  WORDPRESS_DB_NAME = "wordpress";
                  WORDPRESS_DB_USER = "wordpress";
                };
                environmentFiles = [ inst.dbPasswordFile ];
                ports = [
                  "127.0.0.1:${toString inst.port}:80/tcp"
                ];
                extraOptions = [ 
                  "--network=wp-${name}" 
                ];
              }
            ) cfg);

          reverseProxy.hosts = lib.mapAttrs' (
            name: inst: lib.nameValuePair inst.subdomain { httpPort = inst.port; }
          ) cfg;
        };
      };
  };
}