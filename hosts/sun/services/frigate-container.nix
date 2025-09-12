{ pkgs, ... }:
{
  virtualisation.oci-containers.containers.frigate = {
    image = "ghcr.io/blakeblackshear/frigate:0.16.1";

    # Web UI on :5000, RTSP on :8554, WebRTC on :8555 (tcp+udp)
    ports = [
      "8554:8554"
      "8555:8555/tcp"
      "8555:8555/udp"
      "8971:8971"
    ];

    # Persist config, recordings, and cache
    volumes = [
      # Put your config.yml inside /var/lib/frigate (container reads /config/config.yml)
      "/var/lib/frigate:/config"
      # Recordings/exports
      "/srv/frigate/media:/media/frigate"
      # Object cache & thumbnails (fast storage recommended)
      "/var/cache/frigate:/tmp/cache"
    ];

    environment = {
      TZ = "Europe/Madrid";

      LIBVA_DRIVER_NAME = "iHD";

      # Silence vainfo's X warning (not required for ffmpeg, just cleaner logs)
      XDG_RUNTIME_DIR = "/tmp";
    };

    devices = [
        "/dev/dri:/dev/dri"
    ];
    
    capabilities = {
        CAP_PERFMON = true;
    };

    extraOptions = [
      "--shm-size=256m"          # increase shared memory for ffmpeg
      "--security-opt=seccomp=unconfined" # Allow iGPU usage access
    ];
  };

  # Ensure directories exist with sane permissions
  systemd.tmpfiles.rules = [
    "d /var/lib/frigate 0750 root root -"
    "d /srv/frigate/media 0750 root root -"
    "d /var/cache/frigate 0750 root root -"
  ];

  services.caddy.virtualHosts."frigate.brusapa.com".extraConfig = ''
    reverse_proxy https://127.0.0.1:8971 {
      transport http {
        tls_insecure_skip_verify
      }
    }
  '';

  # Allow webrtc access through firewall
  networking.firewall = {
    allowedTCPPorts = [ 8555 ];
    allowedUDPPorts = [ 8555 ];
  };
}
