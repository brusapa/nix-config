{ ... }:
{
  virtualisation.oci-containers.containers.musicassistant = {
    volumes = [ 
      "/var/lib/music-assistant:/data"
    ];
    environment.TZ = "Europe/Madrid";
    environment.LOG_LEVEL = "info";
    # Note: The image will not be updated on rebuilds, unless the version label changes
    image = "ghcr.io/music-assistant/server:latest";
    extraOptions = [ 
      # Use the host network namespace for all sockets
      "--network=host"
    ];
  };

  services.caddy.virtualHosts."musica.brusapa.com".extraConfig = ''
    reverse_proxy http://localhost:8095
  '';
  networking.firewall.allowedTCPPorts = [ 8097 ];


}
