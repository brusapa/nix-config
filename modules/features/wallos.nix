{ den, ... }:
{
  den.aspects.wallos = {
    includes = [
      den.aspects.reverse-proxy
    ];
    nixos = { lib, config, ... }:
      let
        inherit (lib) mkOption types;
        cfg = config.wallos;
        username = "wallos";
        dataPath = "/var/lib/wallos";
      in
      {
        options.wallos = {
          port = mkOption {
            type = types.port;
            default = 8282;
          };

          subdomain = mkOption {
            type = types.str;
            default = "wallos";
            description = "Domain for wallos";
          };
        };

        config = {

          sops = {
            secrets = {
              "wallos/pocketid-id" = {};
              "wallos/pocketid-secret" = {};
            };
            templates."wallos-secrets.env".content = ''
              OIDC_CLIENT_ID=${config.sops.placeholder."wallos/pocketid-id"}
              OIDC_CLIENT_SECRET=${config.sops.placeholder."wallos/pocketid-secret"}
            '';
          };

          users.groups.${username} = { };
          users.users.${username} = {
            group = username;
            isSystemUser = true;
          };

          # Ensure directories exist with sane permissions
          systemd.tmpfiles.rules = [
            "d ${dataPath}/db 0775 ${username} ${username} -"
            "d ${dataPath}/logos 0775 ${username} ${username} -"
          ];

          virtualisation.oci-containers.containers.wallos = {

            image = "ghcr.io/ellite/wallos:5.7.1";

            volumes = [
              "${dataPath}/db:/var/www/html/db"
              "${dataPath}/logos:/var/www/html/images/uploads/logos"
            ];

            environment = {
              TZ = "Europe/Madrid";
              PUID = toString config.users.users.${username}.uid;
              PGID = toString config.users.groups.${username}.gid;
              OIDC_ENABLED = "true";
              OIDC_PROVIDER_NAME = "PocketID";
              OIDC_AUTH_URL = "https://pocketid.${config.reverseProxy.baseDomain}/authorize";
              OIDC_TOKEN_URL = "https://pocketid.${config.reverseProxy.baseDomain}/api/oidc/token";
              OIDC_USERINFO_URL = "https://pocketid.${config.reverseProxy.baseDomain}/api/oidc/userinfo";
              OIDC_REDIRECT_URL = "https://wallos.${config.reverseProxy.baseDomain}/index.php";
              OIDC_LOGOUT_URL = "https://pocketid.${config.reverseProxy.baseDomain}/api/oidc/end-session";
              OIDC_AUTO_CREATE_USER = "true";
              OIDC_DISABLE_PASSWORD_LOGIN = "true";
              SSRF_ALLOWLIST = "pocketid.${config.reverseProxy.baseDomain},10.88.0.1";
            };
            environmentFiles = [
              config.sops.templates."wallos-secrets.env".path
            ];

            ports = [
              "${toString cfg.port}:80/tcp"
            ];
          };

          reverseProxy.hosts.${cfg.subdomain}.httpPort = cfg.port;

        };
      };
  };
}
