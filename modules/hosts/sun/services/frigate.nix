{ den, ... }:
{
  den.aspects.sun = {
    includes = [
      den.aspects.frigate
    ];

    nixos =
      { config, ... }:
      {
        # Import the needed secrets
        sops = {
          secrets = {
            "frigate/mqtt-password" = { };
            "frigate/reolink-rtsp-password" = { };
            "frigate/tapo-admin-password" = { };
          };
          templates."frigate-secrets.env" = {
            content = ''
              FRIGATE_MQTT_PASSWORD=${config.sops.placeholder."frigate/mqtt-password"}
              FRIGATE_REOLINK_RTSP_PASSWORD=${config.sops.placeholder."frigate/reolink-rtsp-password"}
              FRIGATE_TAPO_ADMIN_PASSWORD=${config.sops.placeholder."frigate/tapo-admin-password"}
            '';
          };
        };

        frigate = {
          hwaccel-driver = "iHD";
          media-path = "/mnt/internalBackup/frigate";
          environmentFiles = [
            config.sops.templates."frigate-secrets.env".path
          ];
        };
      };
  };
}
