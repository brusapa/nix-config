{ config, ... }:
{
  imports = [
    ../../../modules/myservices/donetick.nix
  ];

  sops = {
    secrets = {
      "donetick/jwt-secret" = {
        sopsFile = ../secrets.yaml;
      };
      "donetick/oidc-client-id" = {
        sopsFile = ../secrets.yaml;
      };
      "donetick/oidc-client-secret" = {
        sopsFile = ../secrets.yaml;
      };
    };
    templates."donetick-secrets.env" = {
      content = ''
        DT_JWT_SECRET=${config.sops.placeholder."donetick/jwt-secret"}
        DT_OAUTH2_CLIENT_ID=${config.sops.placeholder."donetick/oidc-client-id"}
        DT_OAUTH2_CLIENT_SECRET=${config.sops.placeholder."donetick/oidc-client-secret"}
      '';
    };
  };

  donetick = {
    enable = true;
    environment = {
      DT_IS_USER_CREATION_DISABLED="true";
      DT_OAUTH2_AUTH_URL="https://pocketid.brusapa.com/authorize";
      DT_OAUTH2_TOKEN_URL="https://pocketid.brusapa.com/api/oidc/token";
      DT_OAUTH2_USER_INFO_URL="https://pocketid.brusapa.com/api/oidc/userinfo";
      DT_OAUTH2_REDIRECT_URL="https://donetick.brusapa.com/auth/oauth2";
      DT_OAUTH2_NAME="PocketID";
    };
    environmentFiles = [
      config.sops.templates."donetick-secrets.env".path
    ];
  };

  reverseProxy.hosts.donetick.httpPort = config.donetick.port;
}