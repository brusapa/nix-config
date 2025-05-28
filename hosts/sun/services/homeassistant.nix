{ ... }:
{
  virtualisation.oci-containers = {
    backend = "podman";

    containers.homeassistant = {
      volumes = [ 
        "/var/lib/homeassistant:/config" 
      ];
      environment.TZ = "Europe/Madrid";
      # Note: The image will not be updated on rebuilds, unless the version label changes
      image = "ghcr.io/home-assistant/home-assistant:2025.4";
      extraOptions = [ 
        # Use the host network namespace for all sockets
        "--network=host"
      ];
    };

    containers.zigbee2mqtt = {
      volumes = [
        "/var/lib/zigbee2mqtt:/app/data"
      ];
      environment.TZ = "Europe/Madrid";
      # Note: The image will not be updated on rebuilds, unless the version label changes
      image = "ghcr.io/koenkk/zigbee2mqtt:2.2.1";
      ports = [ 
        "8081:8080" # Zigbee2MQTT web interface
      ];
    };

    containers.mosquitto = {
      volumes = [
        "/var/lib/mosquitto/config:/mosquitto/config" 
        "/var/lib/mosquitto/data:/mosquitto/data"
      ];
      environment.TZ = "Europe/Madrid";
      # Note: The image will not be updated on rebuilds, unless the version label changes
      image = "eclipse-mosquitto:2.0.21";
      ports = [ 
        "1883:1883"
        "9001:9001"
      ];
    }
  };
}
