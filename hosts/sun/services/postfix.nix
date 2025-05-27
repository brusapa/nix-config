{ ... }:
{
  # Import the needed secrets
  sops.secrets."postfix/sasl_passwd" = {
    sopsFile = ../secrets.yaml;
    owner = config.services.postfix.user;
  };
  services.postfix = {
    enable = true;
    #rootAlias = "";
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