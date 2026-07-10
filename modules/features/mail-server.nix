{
  den.aspects.mail-server.nixos = 
    { config, pkgs, ... }:
    {

      # Import the needed secrets
      sops = {
        secrets = {
          "postfix/sasl_passwd" = {
            owner = config.services.postfix.user;
          };
        };
      };

      services.postfix = {
        enable = true;
        setSendmail = true;
        rootAlias = "brusapa@brusapa.com";
        settings.main = {
          relayhost = [
            "[smtp.eu.mailgun.org]:587"
          ];
          myhostname = "${config.networking.hostName}.${config.networking.domain}";
          smtp_use_tls = "yes";
          smtp_tls_security_level = "encrypt";
          smtp_sasl_security_options = "";
          smtp_sasl_auth_enable = "yes";
          smtp_sasl_password_maps = "texthash:${config.sops.secrets."postfix/sasl_passwd".path}";
        };
      };

      environment.systemPackages = [
        pkgs.mailutils
      ];
    };
}
