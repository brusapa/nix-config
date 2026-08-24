{ den, ... }:
{
  den.aspects.reverse-proxy = {
    includes = [
      den.aspects.acme
    ];
    nixos = {
      lib,
      config,
      pkgs,
      ...
    }:
    let
      inherit (lib)
        mkIf
        mkOption
        types
        filterAttrs
        mapAttrs'
        nameValuePair
        ;
      cfg = config.reverseProxy;

      # Only hosts that have at least one port defined
      enabledHosts = filterAttrs (
        _: hostCfg: hostCfg.httpPort != null || hostCfg.httpsPort != null
      ) cfg.hosts;

      mkExtraConfig =
        hostCfg:
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
        baseDomain = mkOption {
          type = types.str;
          default = "brusapa.com";
          description = "Base domain for reverse proxy";
        };

        hosts = mkOption {
          type = types.attrsOf (
            types.submodule (
              { name, ... }: {
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
              }
            )
          );
          default = { };
          description = ''
            Per-host reverse proxy definitions.

            Example:
              reverseProxy.hosts.frigate.httpPort = 8971;
          '';
        };
      };

      config = {
        # Wildcard certificate for base domain
        security.acme.certs."${cfg.baseDomain}" = {
          domain = "*.${cfg.baseDomain}";
          group = config.services.caddy.group;
        };

        services.caddy = {
          enable = true;
          virtualHosts = (
            mapAttrs' (
              name: hostCfg:
              nameValuePair "${name}.${cfg.baseDomain}" {
                useACMEHost = cfg.baseDomain;
                extraConfig = mkExtraConfig hostCfg;
              }
            ) enabledHosts
          );
        };

        networking.firewall.allowedTCPPorts = [
          80
          443
        ];
      };
    };
  };
}
