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
    virtualHosts."jellyfin.brusapa.com".extraConfig = ''
      reverse_proxy http://127.0.0.1:8096
    '';
    virtualHosts."torrent.brusapa.com".extraConfig = ''
      reverse_proxy http://127.0.0.1:9091
    '';
    virtualHosts."usenet.brusapa.com".extraConfig = ''
      reverse_proxy http://127.0.0.1:8080
    '';
    virtualHosts."radarr.brusapa.com".extraConfig = ''
      reverse_proxy http://127.0.0.1:7878
    '';
    virtualHosts."sonarr.brusapa.com".extraConfig = ''
      reverse_proxy http://127.0.0.1:8989
    '';
    virtualHosts."bazarr.brusapa.com".extraConfig = ''
      reverse_proxy http://127.0.0.1:6767
    '';
    virtualHosts."prowlarr.brusapa.com".extraConfig = ''
      reverse_proxy http://127.0.0.1:9696
    '';
    virtualHosts."jellyserr.brusapa.com".extraConfig = ''
      reverse_proxy http://127.0.0.1:5055
    '';
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
