{ lib, config, pkgs, ... }:
{

  # Import the needed secrets
  sops = {
    secrets = {
      "postfix/sasl_passwd" = {
        sopsFile = ../secrets.yaml;
        owner = config.services.postfix.user;
      };
      root-email-alias = {
        sopsFile = ../secrets.yaml;
      };
    };
    templates."postfix-aliases" = {
      content = ''
        postmaster: root
        root: ${config.sops.placeholder.root-email-alias}
      '';
      mode = "0444";
    };
  };

  services.postfix = {
    enable = true;
    setSendmail = true;
    settings.main = {
      relayhost = [
        "[smtp.eu.mailgun.org]:587"
      ];
      smtp_use_tls = "yes";
      smtp_tls_security_level = "encrypt";
      smtp_sasl_security_options = "";
      smtp_sasl_auth_enable = "yes";
      smtp_sasl_password_maps = "texthash:${config.sops.secrets."postfix/sasl_passwd".path}";
    };
    aliasFiles.aliases = lib.mkForce config.sops.templates."postfix-aliases".path;
  };

  environment.systemPackages = [
    pkgs.mailutils
  ];
}
