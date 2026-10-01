{ den, ... }:
{
  den.aspects.ntfy = {
    includes = [
      den.aspects.reverse-proxy
    ];
    nixos =
      { config, ... }:
      let
        port = 34521;
      in 
      {
        # Import the needed secrets
        sops = {
          secrets = {
            "ntfy/bruno-password" = { };
            "ntfy/sun-password" = { };
            "ntfy/beszel-token" = { };
            "ntfy/web-push-public-key" = { };
            "ntfy/web-push-private-key" = { };
          };
          templates."ntfy-secrets.env" = {
            content = ''
              NTFY_AUTH_USERS='bruno:${config.sops.placeholder."ntfy/bruno-password"}:admin,sun:${config.sops.placeholder."ntfy/sun-password"}:user'
              NTFY_AUTH_TOKENS='sun:${config.sops.placeholder."ntfy/beszel-token"}:beszel'
              NTFY_WEB_PUSH_PUBLIC_KEY=${config.sops.placeholder."ntfy/web-push-public-key"}
              NTFY_WEB_PUSH_PRIVATE_KEY=${config.sops.placeholder."ntfy/web-push-private-key"}
            '';
          };
        };

        services.ntfy-sh = {
          enable = true;
          environmentFile = config.sops.templates."ntfy-secrets.env".path;
          settings = {
            listen-http = ":${toString port}";

            # Proxy options
            behind-proxy = true;
            base-url = "https://ntfy.${config.reverseProxy.baseDomain}";

            # Mail options
            smtp-sender-addr = "127.0.0.1:25";
            smtp-sender-from = "ntfy@${config.reverseProxy.baseDomain}";
            # Incoming email
            smtp-server-listen = ":2525";
            smtp-server-domain = "example.com";

            # Auth options
            auth-default-access = "deny-all";
            auth-access = [
              "*:up*:write-only"
              "sun:solarsystemstatus:write-only"
            ];
            enable-login = true;
            require-login = true;

            # Enable push notifications for IoS
            upstream-base-url = "https://ntfy.sh";

            # Web push
            web-push-file = "/var/lib/ntfy-sh/webpush.db"; # or similar
            web-push-email-address = "brusapa@brusapa.com";
          };
        };

        reverseProxy.hosts.ntfy.httpPort = port;
      };
  };
}
