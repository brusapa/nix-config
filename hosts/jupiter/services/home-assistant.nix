{ config, ... }:
{
  imports = [
    ../../../modules/myservices/home-assistant.nix
    ../../../modules/myservices/zigbee2mqtt.nix
    ../../../modules/myservices/mqtt.nix
  ];

  # Import the needed secrets
  sops = {
    secrets = {
      "home-assistant/mqtt-password" = {
        sopsFile = ../secrets.yaml;
      };
    };
  };

  home-assistant = {
    enable = true;
    version = "2026.1";
    subdomain = "casa";
  };

  mqtt = {
    enable = true;
    domain = "mqtt.leioa.brusapa.com";
    hashedPasswordFile = config.sops.secrets."home-assistant/mqtt-password".path;
  };

  zigbee2mqtt.zigbee2mqtt = {
    enable = true;
    version = "2.7.2";
    subdomain = "zigbee2mqtt";
  };
}
