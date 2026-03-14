{ config, ... }:
let 
  version = "v1.51.0";
  port = 7575;
  dataPath = "/var/lib/homarr";
  user = "homarr";
in 
{

  users.groups.${user} = {};
  users.users.${user} = {
    group = "${user}";
    isSystemUser = true;
  };

  systemd.tmpfiles.rules = [
    "d ${dataPath} 0775 ${user} ${user} -"
  ];

  # Import the needed secrets
  sops = {
    secrets = {
      "homarr/encryption-key" = {
        sopsFile = ../secrets.yaml;
      };
      "homarr/nextauth-secret" = {
        sopsFile = ../secrets.yaml;
      };
      "homarr/pocketid-client-id" = {
        sopsFile = ../secrets.yaml;
      };
      "homarr/pocketid-client-secret" = {
        sopsFile = ../secrets.yaml;
      };
    };
    templates."homarr-secrets.env" = {
      content = ''
        SECRET_ENCRYPTION_KEY=${config.sops.placeholder."homarr/encryption-key"}
        NEXTAUTH_SECRET=${config.sops.placeholder."homarr/nextauth-secret"}
        AUTH_OIDC_CLIENT_ID=${config.sops.placeholder."homarr/pocketid-client-id"}
        AUTH_OIDC_CLIENT_SECRET=${config.sops.placeholder."homarr/pocketid-client-secret"}
      '';
    };
  };

  virtualisation.oci-containers.containers.homarr = {
    image = "ghcr.io/homarr-labs/homarr:${version}";

    ports = [
      "${toString port}:7575"
    ];

    volumes = [
      "${dataPath}:/appdata"
    ];

    environment = {
      PUID = toString config.users.users.${user}.uid;
      PGID = toString config.users.groups.${user}.gid;
      AUTH_PROVIDERS="oidc";
      AUTH_OIDC_ISSUER="https://pocketid.brusapa.com";
      AUTH_OIDC_CLIENT_NAME="Pocket ID";
      AUTH_OIDC_SCOPE_OVERWRITE="openid email profile groups";
      AUTH_OIDC_GROUPS_ATTRIBUTE="groups";
      AUTH_LOGOUT_REDIRECT_URL="https://pocketid.brusapa.com";
      AUTH_OIDC_AUTO_LOGIN="true";
    };

    environmentFiles = [
      config.sops.templates."homarr-secrets.env".path
    ];
  };


  reverseProxy.hosts.homarr.httpPort = port;
}