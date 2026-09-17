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
          inet_interfaces = "127.0.0.1 10.88.0.1";
          mynetworks = [ 
            "127.0.0.0/8" 
            "10.88.0.0/16"
          ];
          smtpd_relay_restrictions = "permit_mynetworks,reject";
          smtpd_recipient_restrictions = "permit_mynetworks,reject_unauth_destination";
        };
      };

      # Allow containers to send emails
      networking.firewall.interfaces."podman0".allowedTCPPorts = [ 25 ];

      environment.systemPackages = [
        pkgs.mailutils
      ];
    };
}
