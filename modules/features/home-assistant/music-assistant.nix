{ den, ... }:
{
  den.aspects.music-assistant = {
    includes = [
      den.aspects.reverse-proxy
    ];

    nixos = {
      services.music-assistant = {
        enable = true;
        openFirewall = true;
        providers = [
          "spotify"
          "sonos"
          "sendspin"
          "jellyfin"
          "chromecast"
          "hass"
          "hass_players"
        ];
      };

      reverseProxy.hosts.musica.httpPort = 8095;
    };
  };
}
