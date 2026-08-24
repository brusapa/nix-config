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
          };
          templates."ntfy-secrets.env" = {
            content = ''
              NTFY_AUTH_USERS='bruno:${config.sops.placeholder."ntfy/bruno-password"}:admin,sun:${config.sops.placeholder."ntfy/sun-password"}:user'
            '';
          };
        };

        services.ntfy-sh = {
          enable = true;
          environmentFile = config.sops.templates."ntfy-secrets.env".path;
          settings = {
            listen-http = ":${toString port}";
            behind-proxy = true;
            base-url = "https://ntfy.${config.reverseProxy.baseDomain}";
            smtp-sender-addr = "127.0.0.1:25";
            smtp-sender-from = "ntfy@${config.reverseProxy.baseDomain}";
            auth-default-access = "deny-all";
            enable-login = true;
            require-login = true;
          };
        };

        reverseProxy.hosts.ntfy.httpPort = port;
      };
  };
}
