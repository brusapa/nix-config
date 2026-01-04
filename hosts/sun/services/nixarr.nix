{ inputs, config, ... }:

{
  imports = [
    inputs.nixarr.nixosModules.default
  ];

  # Import the needed secrets
  sops = {
    secrets = {
      torrent-wireguard-config = {
        sopsFile = ../secrets.yaml;
      };
    };
  };

  # Fix the GID of the media group
  users.groups.media.gid = 169;

  nixarr = {
    enable = true;
    # These two values are also the default, but you can set them to whatever
    # else you want
    # WARNING: Do _not_ set them to `/home/user/whatever`, it will not work!
    mediaDir = "/zstorage/media";
    stateDir = "/data/media/.state/nixarr";
    mediaUsers = [ "bruno" ];

    vpn = {
      enable = true;
      wgConf = config.sops.secrets.torrent-wireguard-config.path;
    };

    jellyfin = {
      enable = true;
      openFirewall = true;
    };

    sabnzbd = {
      enable = false;
      vpn.enable = true;
      openFirewall = false;
      whitelistHostnames = [
        "usenet.brusapa.com"
      ];
    };

    # It is possible for this module to run the *Arrs through a VPN, but it
    # is generally not recommended, as it can cause rate-limiting issues.
    bazarr = {
      enable = false;
      openFirewall = false;
    };
    prowlarr = {
      enable = false;
      openFirewall = false;
    };
    radarr = {
      enable = false;
      openFirewall = false;
    };
    sonarr = {
      enable = false;
      openFirewall = false;
    };
    lidarr = {
      enable = false;
      openFirewall = false;
    };
    jellyseerr = {
      enable = true;
      openFirewall = false;
    };
  };

  # services.jackett = {
  #   enable = true;
  # };
  # vpnNamespaces.wg = {
  #   portMappings = [{
  #     from = 9117;
  #     to = 9117;
  #   }];
  # };
  # systemd.services.jackett.vpnconfinement = {
  #   enable = true;
  #   vpnnamespace = "wg";
  # };

  # Add jellyfin user to render group
  users.users.jellyfin.extraGroups = [ "render" ];

  reverseProxy.hosts.jellyfin.httpPort = 8096;
  reverseProxy.hosts.jellyserr.httpPort = config.nixarr.jellyseerr.port;

}
