{ lib, config, ... }:
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
    setSendmail = false;
    settings.main = {
      relayHost = [
        "smtp.eu.mailgun.org:587"
      ];
      smtp_use_tls = "yes";
      smtp_sasl_auth_enable = "yes";
      smtp_sasl_security_options = "";
      smtp_sasl_password_maps = "texthash:${config.sops.secrets."postfix/sasl_passwd".path}";
    };
    aliasFiles.aliases = lib.mkForce config.sops.templates."postfix-aliases".path;
  };

  programs.msmtp = {
    enable = true;
    setSendmail = true;
    defaults = {
      aliases = config.sops.templates."postfix-aliases".path;
      port = 25;
      tls = false;
    };
    accounts = {
      default = {
        auth = false;
        host = "127.0.0.1";
        from = "sun@brusapa.com";
      };
    };
  };
}
