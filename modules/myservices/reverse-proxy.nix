{ lib, config, pkgs, ... }:
let
  inherit (lib) mkIf mkOption  mkEnableOption types filterAttrs mapAttrs' nameValuePair;
  cfg = config.reverseProxy;

   # Only hosts that have at least one port defined
  enabledHosts =
    filterAttrs (_: hostCfg:
      hostCfg.httpPort != null || hostCfg.httpsPort != null
    ) cfg.hosts;

  mkExtraConfig = hostCfg:
    if hostCfg.httpsPort != null then
      ''
        reverse_proxy https://${hostCfg.ip}:${toString hostCfg.httpsPort} {
          transport http {
            tls_insecure_skip_verify
          }
        }
      ''
    else
      ''
        reverse_proxy http://${hostCfg.ip}:${toString hostCfg.httpPort}
      '';
in
{
  options.reverseProxy = {
    enable = mkEnableOption "Enable reverseProxy";

    httpPort = mkOption {
      type = types.port;
      default = 80;
    };
    
    httpsPort = mkOption {
      type = types.port;
      default = 443;
    };

    baseDomain = mkOption {
      type = types.str;
      default = "brusapa.com";
      description = "Base domain for reverse proxy";
    };

    environmentFile = mkOption {
      type = types.path;
      description = "Secrets environment file";
    };

    user = mkOption {
      type = types.str;
      default = "caddy";
      description = "User account under which the reverse proxy runs.";
    };

    group = mkOption {
      type = types.str;
      default = "caddy";
      description = "Group under which the reverse proxy runs.";
    };


    hosts = mkOption {
      type = types.attrsOf (types.submodule ({ name, ... }: {
        options = {
          ip = mkOption {
            type = types.str;
            default = "127.0.0.1";
            description = "Hostname or IP of the upstream for `${name}`.";
          };
          httpPort = mkOption {
            type = types.nullOr types.port;
            default = null;
            description = "Insecure port to proxy for host `${name}`.";
          };
          httpsPort = mkOption {
            type = types.nullOr types.port;
            default = null;
            description = ''
              Secure port to proxy for host `${name}`.
              If set, it takes precedence over `httpPort`.
            '';
          };
        };
      }));
      default = { };
      description = ''
        Per-host reverse proxy definitions.

        Example:
          reverseProxy.hosts.frigate.httpPort = 8971;
      '';
    };
  };

  config = mkIf cfg.enable {

    systemd.services.caddy.serviceConfig.EnvironmentFile = cfg.environmentFile;

    services.caddy = {
      enable = true;
      user = cfg.user;
      group = cfg.group;
      package = pkgs.caddy.withPlugins {
        plugins = [ "github.com/caddy-dns/cloudflare@v0.2.2" ];
        hash = "sha256-dnhEjopeA0UiI+XVYHYpsjcEI6Y1Hacbi28hVKYQURg=";
      };
      globalConfig = 
      ''
        email {env.CF_EMAIL}
        acme_dns cloudflare {env.CF_API_TOKEN}
      '';
       virtualHosts =
        (mapAttrs' (name: hostCfg:
          nameValuePair "${name}.${cfg.baseDomain}" {
            extraConfig = mkExtraConfig hostCfg;
          }
        ) enabledHosts);
    };

    networking.firewall.allowedTCPPorts = [ cfg.httpPort cfg.httpsPort ];
  };
}
