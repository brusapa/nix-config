{ config, ... }:
{

  # Import the needed secrets
  sops.secrets = {
    "postfix/sasl_passwd" = {
      sopsFile = ../secrets.yaml;
      owner = config.services.postfix.user;
    };
    root-email-alias = {
      sopsFile = ../secrets.yaml;
    };
    templates."postfix-secrets.env" = {
      content = ''
        ROOT_EMAIL_ALIAS="${config.sops.placeholder.root-email-alias}"
      '';
      owner = config.services.postfix.user;
    };
  };

  systemd.services.postfix.serviceConfig.EnvironmentFile = config.sops.templates."postfix-secrets.env".path;

  services.postfix = {
    enable = true;
    rootAlias = "{env.ROOT_EMAIL_ALIAS}";
    relayHost = "smtp.eu.mailgun.org";
    relayPort = 587;
    config = {
      smtp_use_tls = "yes";
      smtp_sasl_auth_enable = "yes";
      smtp_sasl_security_options = "";
      smtp_sasl_password_maps = "texthash:${config.sops.secrets."postfix/sasl_passwd".path}";
    };
  };
}