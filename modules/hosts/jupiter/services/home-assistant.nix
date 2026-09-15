{ den, ... }:
{
  den.aspects.jupiter = {
    includes = [
      den.aspects.mqtt
      den.aspects.zigbee2mqtt
      den.aspects.home-assistant
      den.aspects.frigate
    ];

    nixos = {
        zigbee2mqtt = { };
        home-assistant.subdomain = "casa";
        frigate = {
          hwaccel-driver = "radeonsi";
          media-path = "/znvme/frigate";
        };
      };
  };
}
