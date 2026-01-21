{ lib, config, ... }:
let
  inherit (lib) mkOption  mkEnableOption types mkIf;
  cfg = config.acme;
in
{
  options.acme = {
    enable = mkEnableOption "Enable acme";

    email = mkOption {
      type = types.str;
      default = "brusapa@brusapa.com";
      description = "Email used for ACME";
    };

    cloudflareTokenFile = mkOption {
      type = types.path;
      default = null;
      description = "Cloudflare token file";
    };
  };

  config = mkIf cfg.enable {

    security.acme = {
      acceptTerms = true;
      defaults = {
        email = cfg.email;
        dnsProvider = "cloudflare";
        credentialFiles = {
          "CF_DNS_API_TOKEN_FILE" = cfg.cloudflareTokenFile;
        };
      };
    };

  };
}
