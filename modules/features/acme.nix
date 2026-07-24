{
  den.aspects.acme.nixos = { config, ... }: {

    # Import the needed secrets
    sops = {
      secrets = {
        "acme/token" = { };
      };
      templates."acme-secrets.env" = {
        content = ''
          CLOUDFLARE_DNS_API_TOKEN=${config.sops.placeholder."acme/token"}
          CLOUDFLARE_PROPAGATION_TIMEOUT=600
          CLOUDFLARE_POLLING_INTERVAL=10
        '';
      };
    };

    security.acme = {
      acceptTerms = true;
      defaults = {
        email = "brusapa@brusapa.com";
        dnsProvider = "cloudflare";
        dnsResolver = "1.1.1.1:53";
        environmentFile = config.sops.templates."acme-secrets.env".path;
      };
    };
  };
}
