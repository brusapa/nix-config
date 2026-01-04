{ lib, config, ... }:
let
  inherit (lib) mkIf mkOption  mkEnableOption types;
  cfg = config.myservices.frigate;
in
{
  options.myservices.frigate = {
    enable = mkEnableOption "Enable frigate";

    name = mkOption {
      type = types.str;
      default = "frigate";
    };

    version = mkOption {
      type = types.str;
      default = "latest";
    };

    port = mkOption {
      type = types.port;
      default = 8971;
    };

    mediaPath = mkOption {
      type = types.path;
      default = "/var/lib/frigate/${cfg.name}/media";
      description = "Path to store recordings and exports";
    };
  };

  config = mkIf cfg.enable {

    # Ensure directories exist with sane permissions
    systemd.tmpfiles.rules = [
      "d /var/lib/frigate/${cfg.name}/config 0750 root root -"
      "d ${cfg.mediaPath} 0750 root root -"
    ];

    virtualisation.oci-containers.containers.${cfg.name} = {
      volumes = [
        "/var/lib/frigate/${cfg.name}/config:/config"
        "${cfg.mediaPath}:/media/frigate"
      ];
      
      environment = {
        TZ = "Europe/Madrid";
        LIBVA_DRIVER_NAME = "iHD";
        # Silence vainfo's X warning (not required for ffmpeg, just cleaner logs)
        XDG_RUNTIME_DIR = "/tmp";
      };

      image = "ghcr.io/koenkk/frigate:${cfg.version}";

      ports = [
        "${toString cfg.port}:8971/tcp"
        "8554:8554/tcp"
        "8555:8555/tcp"
        "8555:8555/udp"
      ];

      devices = [
        "/dev/dri:/dev/dri"
      ];

      capabilities = {
        CAP_PERFMON = true;
      };

      extraOptions = [
        "--shm-size=256m" # increase shared memory for ffmpeg
        "--security-opt=seccomp=unconfined" # Allow iGPU usage access
        "--mount type=tmpfs,tmpfs-size=1024M,destination=/tmp/cache" # Optional: 1GB of memory, reduces SSD/SD Card wear
      ];
    };

    reverseProxy.hosts.${cfg.name}.httpsPort = cfg.port;

    # Allow webrtc access through firewall
    networking.firewall = {
      allowedTCPPorts = [ 8555 ];
      allowedUDPPorts = [ 8555 ];
    };

  };
}
