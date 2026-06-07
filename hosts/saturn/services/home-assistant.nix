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
    version = "2026.3"; # TODO: Match to the old version
    subdomain = "casa";
  };

  mqtt = {
    enable = true;
    domain = "mqtt.sonabia.brusapa.com";
    hashedPasswordFile = config.sops.secrets."home-assistant/mqtt-password".path;
  };

  zigbee2mqtt = {
    zigbeecasa = {
      enable = true;
      version = "2.7.2"; # TODO: Match to the old version
      subdomain = "zigbeecasa";
    };
    zigbeegaraje = {
      enable = true;
      version = "2.7.2";  # TODO: Match to the old version
      subdomain = "zigbeegaraje";
    };
  };
}
