{ den, ... }:
{
  den.aspects.lldap = {

    includes = [
      den.aspects.reverse-proxy
    ];

    nixos =
      { config, ... }:
      {
        # Import the needed secrets
        sops.secrets."lldap/admin-password" = {
          # owner/mode left at default: root:root 0400
          restartUnits = [ "lldap.service" ];
        };
        sops.secrets."lldap/jwt-secret".restartUnits = [ "lldap.service" ];

        systemd.services.lldap.serviceConfig.LoadCredential = [
          "admin-pass:${config.sops.secrets."lldap/admin-password".path}"
          "jwt-secret:${config.sops.secrets."lldap/jwt-secret".path}"
        ];

        services.lldap = {
          enable = true;
          environment = {
            # %d expands to $CREDENTIALS_DIRECTORY (systemd ≥ 248)
            LLDAP_LDAP_USER_PASS_FILE = "%d/admin-pass";
            LLDAP_JWT_SECRET_FILE = "%d/jwt-secret";
          };
          settings = {
            force_ldap_user_pass_reset = "always";
            ldap_base_dn = "dc=brusapa,dc=com";
            http_url = "https://lldap.${config.reverseProxy.baseDomain}";
          };
        };

        reverseProxy.hosts.lldap.httpPort = config.services.lldap.settings.http_port;
      };
  };
}
