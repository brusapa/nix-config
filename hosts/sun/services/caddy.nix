{ pkgs, config, ... }:
{
  # Import the needed secrets
  sops = {
    secrets = {
      cloudflare-email = {
        sopsFile = ../secrets.yaml;
      };
      cloudflare-api-token = {
        sopsFile = ../secrets.yaml;
      };
    };
    templates."caddy-secrets.env" = {
      content = ''
        CF_EMAIL="${config.sops.placeholder.cloudflare-email}"
        CF_API_TOKEN="${config.sops.placeholder.cloudflare-api-token}"
      '';
      owner = "caddy";
    };
  };

  systemd.services.caddy.serviceConfig.EnvironmentFile = config.sops.templates."caddy-secrets.env".path;

  services.caddy = {
    enable = true;
    package = pkgs.caddy.withPlugins {
      plugins = [ "github.com/caddy-dns/cloudflare@v0.2.1" ];
      hash = "sha256-Gsuo+ripJSgKSYOM9/yl6Kt/6BFCA6BuTDvPdteinAI=";
    };
    globalConfig = 
    ''
      email {env.CF_EMAIL}
      acme_dns cloudflare {env.CF_API_TOKEN}
    '';
    virtualHosts."router.brusapa.com".extraConfig = ''
      reverse_proxy 10.80.0.1:443
      transport http {
        tls
        tls_insecure_skip_verify
      }
    '';
    virtualHosts."ender.brusapa.com".extraConfig = ''
      reverse_proxy http://10.80.0.3
    '';
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
