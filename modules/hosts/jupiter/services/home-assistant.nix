{ den, ...}:
{
  den.aspects.jupiter = {
    includes = [
      den.aspects.mqtt
      den.aspects.zigbee2mqtt
      den.aspects.home-assistant
    ];

    nixos = 
      {

        # Home assistant
        mqtt.domain = "mqtt.leioa.brusapa.com";
        zigbee2mqtt = {};
        home-assistant.subdomain = "casa";

      };
  };
}


