{
  den.aspects.acme.nixos = { config, ... }: {

    # Import the needed secrets
    sops.secrets = {
      "acme/token" = { };
    };

    security.acme = {
      acceptTerms = true;
      defaults = {
        email = "brusapa@brusapa.com";
        dnsProvider = "cloudflare";
        credentialFiles = {
          "CF_DNS_API_TOKEN_FILE" = config.sops.secrets."acme/token".path;
        };
      };
    };
  };
}