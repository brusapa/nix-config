{ den, ... }:
{
  den.aspects.frigate = {
    includes = [
      den.aspects.reverse-proxy
    ];

    nixos =
      { lib, config, ... }:
      let
        inherit (lib) mkOption types;
        cfg = config.frigate;
      in
      {
        options.frigate = {
          subdomain = mkOption {
            type = types.str;
            default = "frigate";
          };

          port = mkOption {
            type = types.port;
            default = 8971;
          };

          hwaccel-driver = mkOption {
            type = types.str;
            default = "iHD";
            description = "iHD for intel. radeonsi for AMD";
          };

          media-path = mkOption {
            type = types.path;
            default = "/var/lib/frigate/media";
            description = "Path to store recordings and exports";
          };

          environmentFiles = mkOption {
            type = types.listOf types.path;
            default = [ ];
            description = ''
              List of files with environment variables to pass to the container
              (e.g. paths from sops-nix secrets), for things like
              FRIGATE_RTSP_PASSWORD, FRIGATE_MQTT_PASSWORD, etc.
            '';
          };
        };

        config = {

          # Ensure directories exist with sane permissions
          systemd.tmpfiles.rules = [
            "d /var/lib/frigate/config 0775 root root -"
            "d ${cfg.media-path} 0775 root root -"
          ];

          virtualisation.oci-containers.containers.frigate = {
            volumes = [
              "/var/lib/frigate/config:/config"
              "${cfg.media-path}:/media/frigate"
            ];

            environment = {
              TZ = "Europe/Madrid";
              LIBVA_DRIVER_NAME = cfg.hwaccel-driver;
              # Silence vainfo's X warning (not required for ffmpeg, just cleaner logs)
              XDG_RUNTIME_DIR = "/tmp";
            };

            environmentFiles = cfg.environmentFiles;

            # update-image: ^[0-9]+\.[0-9]+\.[0-9]+$
            image = "ghcr.io/blakeblackshear/frigate:0.18.0";

            ports = [
              "127.0.0.1:${toString cfg.port}:8971/tcp"
              "8554:8554/tcp"
              "8555:8555/tcp"
              "8555:8555/udp"
            ];

            devices = [
              "/dev/dri:/dev/dri"
            ];

            extraOptions = [
              "--shm-size=256m" # increase shared memory for ffmpeg
              "--security-opt=seccomp=unconfined" # Allow iGPU usage access
            ];
          };

          reverseProxy.hosts.frigate.httpsPort = cfg.port;

          # Allow webrtc access through firewall
          networking.firewall = {
            allowedTCPPorts = [ 8555 ];
            allowedUDPPorts = [ 8555 ];
          };

        };
      };
  };
}
