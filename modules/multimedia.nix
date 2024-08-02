{ inputs, lib, config, pkgs, ... }:

{

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  networking.firewall.allowedTCPPorts = [
    57621 # Spotify. To sync local tracks from your filesystem with mobile devices in the same network. https://nixos.wiki/wiki/Spotify
  ];

  networking.firewall.allowedUDPPorts = [
    5353 # Spotify. Enable discovery of Google Cast devices. https://nixos.wiki/wiki/Spotify
  ];

}