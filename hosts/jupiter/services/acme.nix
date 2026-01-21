{ config, ... }:
{
  imports = [
    ../../../modules/myservices/acme.nix
  ];

  # Import the needed secrets
  sops = {
    secrets = {
      "acme/token" = {
        sopsFile = ../secrets.yaml;
      };
    };
  };

  acme = {
    enable = true;
    cloudflareTokenFile = config.sops.secrets."acme/token".path;
  };
}