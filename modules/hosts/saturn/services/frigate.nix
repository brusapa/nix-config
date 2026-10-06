{ den, ... }:
{
  den.aspects.saturn = {
    includes = [
      den.aspects.frigate
      den.aspects.mqtt
    ];

    nixos =
      { config, ... }:
      {
        # Import the needed secrets
        sops = {
          secrets = {
            "frigate/mqtt-password" = { };
            "frigate/reolink-rtsp-password" = { };
          };
          templates."frigate-secrets.env" = {
            content = ''
              FRIGATE_MQTT_PASSWORD=${config.sops.placeholder."frigate/mqtt-password"}
              FRIGATE_REOLINK_RTSP_PASSWORD=${config.sops.placeholder."frigate/reolink-rtsp-password"}
            '';
          };
        };

        frigate = {
          hwaccel-driver = "iHD";
          media-path = "/zsonabia/frigate";
          environmentFiles = [
            config.sops.templates."frigate-secrets.env".path
          ];
        };
      };
  };
}
