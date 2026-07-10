{ den, ...}:
{
  den.aspects.mqtt = {

    includes = [
      den.aspects.acme
    ];

    nixos = 
    { lib, config, ... }:
    let
      inherit (lib) mkOption  mkEnableOption types mkIf;
      cfg = config.mqtt;
    in
    {
      options.mqtt = {
        port = mkOption {
          type = types.int;
          default = 1883;
        };

        tlsPort = mkOption {
          type = types.int;
          default = 8883;
        };

        domain = mkOption {
          type = types.str;
          default = "mqtt.brusapa.com";
          example = "mqtt";
          description = "Domain for this mqtt broker instance";
        };
      };

      config = {

        sops.secrets."mqtt/mosquitto-password" = {};

        # Generate TLS certificates
        users.groups.acme.members = [ "mosquitto" ];
        security.acme.certs."${cfg.domain}" = {
          reloadServices = [
            "mosquitto"
          ];
        };

        services.mosquitto = {
          enable = true;
          listeners =[
            {
              port = cfg.port;
              address = "127.0.0.1";
              settings = {
                allow_anonymous = false;
              };
              users.mosquitto = {
                acl = [
                  "readwrite #"
                ];
                hashedPasswordFile = config.sops.secrets."mqtt/mosquitto-password".path;
              };
            }
            {
              port = cfg.tlsPort;
              address = "0.0.0.0";
              settings = let
                certDir = config.security.acme.certs."${cfg.domain}".directory;
              in {
                allow_anonymous = false;
                keyfile = certDir + "/key.pem";
                certfile = certDir + "/cert.pem";
                cafile = certDir + "/chain.pem";
              };
              users.mosquitto = {
                acl = [
                  "readwrite #"
                ];
                hashedPasswordFile = config.sops.secrets."mqtt/mosquitto-password".path;
              };
            }
          ];
        };

        networking.firewall = {
          enable = true;
          allowedTCPPorts = [ cfg.tlsPort ];
        };

      };
    };
  };
}
