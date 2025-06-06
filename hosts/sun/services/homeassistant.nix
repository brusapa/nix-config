{ pkgs, ... }:
{
  virtualisation.oci-containers = {
    backend = "podman";

    containers.homeassistant = {
      volumes = [ 
        "homeassistant:/config" 
      ];
      environment.TZ = "Europe/Madrid";
      # Note: The image will not be updated on rebuilds, unless the version label changes
      image = "ghcr.io/home-assistant/home-assistant:2025.5";
      extraOptions = [ 
        # Use the host network namespace for all sockets
        "--network=host"
      ];
    };

    containers.zigbee2mqtt = {
      volumes = [
        "zigbee2mqtt:/app/data"
      ];
      environment.TZ = "Europe/Madrid";
      # Note: The image will not be updated on rebuilds, unless the version label changes
      image = "ghcr.io/koenkk/zigbee2mqtt:2.3.0";
      ports = [ 
        "8081:8080" # Zigbee2MQTT web interface
      ];
    };

    containers.mosquitto = {
      volumes = [
        "mosquitto-config:/mosquitto/config" 
        "mosquitto-data:/mosquitto/data"
      ];
      environment.TZ = "Europe/Madrid";
      # Note: The image will not be updated on rebuilds, unless the version label changes
      image = "eclipse-mosquitto:2.0.21";
      ports = [ 
        "1883:1883"
        "9001:9001"
      ];
    };
  };

  # Glances for homeassistant monitoring of the server
  services.glances = {
    enable = true;
  };
  services.caddy.virtualHosts."glances.brusapa.com".extraConfig = ''
    reverse_proxy http://127.0.0.1:61208
  '';

  services.caddy.virtualHosts."casa.brusapa.com".extraConfig = ''
    reverse_proxy http://127.0.0.1:8123
  '';
  services.caddy.virtualHosts."zigbee2mqtt.brusapa.com".extraConfig = ''
    reverse_proxy http://127.0.0.1:8081
  '';
  networking.firewall.allowedTCPPorts = [ 8081 8123 ];

  nixpkgs =  {
    # Set ctranslate2 cuda support
    overlays = [
      (final: prev: {
        ctranslate2 = prev.ctranslate2.override {
          withCUDA = true;
          withCuDNN = true;
        };
      })
    ];
  };

  #  environment.systemPackages = with pkgs; [
  #    python3Packages.pytorch-bin
  #  whisper-ctranslate2
  #];

  #services.wyoming.faster-whisper.servers.homeassistant = {
  #  enable = true;
  #  device = "cuda";
  #  uri = "tcp://0.0.0.0:10300";
  #  model = "medium";
  #  language = "es";
  #};
  #services.wyoming.piper.servers.homeassistant = {
  #  enable = true;
  #  voice = "es_ES-mls_10246-low";
  #  uri = "tcp://0.0.0.0:10200";
  #};

}
