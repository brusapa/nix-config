{ lib, config, ... }:
let
  inherit (lib) mkOption  mkEnableOption types mkIf;
  cfg = config.mqtt;
in
{
  options.mqtt = {
    enable = mkEnableOption "Enable mqtt broker";

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
      example = "casa";
      description = "Domain for this mqtt broker instance";
    };

    hashedPasswordFile = mkOption {
      type = types.path;
      default = null;
      description = "Hashed password file path for mqtt broker";
    };
  };

  config = mkIf cfg.enable {

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
            hashedPasswordFile = cfg.hashedPasswordFile;
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
            hashedPasswordFile = cfg.hashedPasswordFile;
          };
        }
      ];
    };

    networking.firewall = {
      enable = true;
      allowedTCPPorts = [ cfg.tlsPort ];
    };

  };
}
