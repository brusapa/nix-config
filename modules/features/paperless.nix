{ den, ... }:
{
  den.aspects.paperless = {
    includes = [
      den.aspects.reverse-proxy
    ];

    nixos =
      { config, lib, ... }:
      let
        inherit (lib) mkOption types;
        cfg = config.paperless;
      in
      {

        options.paperless = {
          subdomain = mkOption {
            type = types.str;
            default = "documentos";
            example = "documentos";
            description = "Subdomain for this paperless instance";
          };

          backupPath = mkOption {
            type = types.nullOr types.path;
            default = null;
            description = "Path for paperless backups (null disables backups)";
          };

          enableGmail = mkOption {
            type = types.bool;
            default = false;
            description = "Whenever enable gmail processing";
          };
        };

        config = {

          # Import the needed secrets
          sops = {
            secrets = {
              "paperless/admin-email" = { };
              "paperless/admin-password" = { };
              "paperless/pocketid-client-id" = { };
              "paperless/pocketid-client-secret" = { };
            }
            // lib.optionalAttrs cfg.enableGmail {
              "paperless/gmail-oauth-client-id" = { };
              "paperless/gmail-oauth-client-secret" = { };
            };
            templates."paperless-secrets.env" = {
              content = ''
                PAPERLESS_ADMIN_MAIL="${config.sops.placeholder."paperless/admin-email"}"
                PAPERLESS_SOCIALACCOUNT_PROVIDERS='{"openid_connect":{"SCOPE":["openid","profile","email"],"OAUTH_PKCE_ENABLED":true,"APPS":[{"provider_id":"pocket-id","name":"Pocket-ID","client_id":"${
                  config.sops.placeholder."paperless/pocketid-client-id"
                }","secret":"${
                  config.sops.placeholder."paperless/pocketid-client-secret"
                }","settings":{"server_url":"https://pocketid.${config.reverseProxy.baseDomain}"}}]}}'
                ${lib.optionalString cfg.enableGmail ''
                  PAPERLESS_GMAIL_OAUTH_CLIENT_ID="${config.sops.placeholder."paperless/gmail-oauth-client-id"}"
                  PAPERLESS_GMAIL_OAUTH_CLIENT_SECRET="${
                    config.sops.placeholder."paperless/gmail-oauth-client-secret"
                  }"
                ''}
              '';
            };
          };

          # Create backup directory if it does not exist
          systemd.tmpfiles.rules = [
            "d ${cfg.backupPath} 0755 ${config.services.paperless.user} ${config.services.paperless.user} -"
          ];

          services.paperless = {
            enable = true;
            dataDir = "/zstorage/paperless";
            settings = {
              PAPERLESS_ADMIN_USER = "bruno";
              # PAPERLESS_OCR_LANGUAGE = "spa+eus+eng"; # Removed due to long building times
              PAPERLESS_URL = "https://${cfg.subdomain}.${config.reverseProxy.baseDomain}";
              PAPERLESS_APPS = "allauth.socialaccount.providers.openid_connect";
            };
            passwordFile = config.sops.secrets."paperless/admin-password".path;
            environmentFile = config.sops.templates."paperless-secrets.env".path;
            exporter = {
              enable = cfg.backupPath != null;
              onCalendar = "daily";
              directory = cfg.backupPath;
              settings = {
                no-color = true;
                no-progress-bar = true;
              };
            };
          };

          reverseProxy.hosts.${cfg.subdomain}.httpPort = config.services.paperless.port;
        };
      };
  };
}
