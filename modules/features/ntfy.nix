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
            "ntfy/pluto-password" = { };
            "ntfy/beszel-token" = { };
            "ntfy/healthchecks-token" = { };
            "ntfy/web-push-public-key" = { };
            "ntfy/web-push-private-key" = { };
          };
          templates."ntfy-secrets.env" = {
            content = ''
              NTFY_AUTH_USERS='bruno:${config.sops.placeholder."ntfy/bruno-password"}:admin,sun:${
                config.sops.placeholder."ntfy/sun-password"
              }:user,pluto:${config.sops.placeholder."ntfy/pluto-password"}:user'
              NTFY_AUTH_TOKENS='pluto:${config.sops.placeholder."ntfy/beszel-token"}:beszel,pluto:${
                config.sops.placeholder."ntfy/healthchecks-token"
              }:healthchecks'
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
            base-url = "https://ntfy.external.brusapa.com";

            # Mail options
            smtp-sender-addr = "127.0.0.1:25";
            smtp-sender-from = "ntfy@$brusapa.com";
            # Incoming email
            #smtp-server-listen = ":2525";
            #smtp-server-domain = "example.com";

            # Auth options
            auth-default-access = "deny-all";
            auth-access = [
              "*:up*:write-only"
              "sun:solarsystemstatus:write-only"
              "pluto:solarsystemstatus:write-only"
            ];
            enable-login = true;
            require-login = true;

            # Web push
            web-push-file = "/var/lib/ntfy-sh/webpush.db";
            web-push-email-address = "brusapa@brusapa.com";
          };
        };

        reverseProxy.hosts.ntfy.httpPort = port;
      };
  };
}
