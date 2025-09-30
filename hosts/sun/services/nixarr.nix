{ inputs, pkgs, config, ... }:

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
      transmission-rpc-password = {
        sopsFile = ../secrets.yaml;
      };
    };
    templates."transmission-credentials" = {
      content = ''
        {
          "rpc-username": "bruno",
          "rpc-password": "${config.sops.placeholder.transmission-rpc-password}"
        }
      '';
      owner = config.util-nixarr.globals.transmission.user;
    };
  };

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

    transmission = {
      enable = true;
      openFirewall = false;
      credentialsFile = config.sops.templates."transmission-credentials".path;
      extraSettings = {
        rpc-authentication-required = true;
      };
      vpn.enable = true;
      peerPort = 56258; # Set this to the port forwarded by your VPN
    };

    sabnzbd = {
      enable = true;
      vpn.enable = true;
      openFirewall = false;
      whitelistHostnames = [
        "usenet.brusapa.com"
      ];
    };

    # It is possible for this module to run the *Arrs through a VPN, but it
    # is generally not recommended, as it can cause rate-limiting issues.
    bazarr = {
      enable = true;
      openFirewall = false;
    };
    prowlarr = {
      enable = true;
      openFirewall = false;
    };
    radarr = {
      enable = true;
      openFirewall = false;
    };
    sonarr = {
      enable = true;
      openFirewall = false;
    };
    lidarr = {
      enable = true;
      openFirewall = false;
    };
    jellyseerr = {
      enable = true;
      openFirewall = false;
    };
  };

  services.jackett = {
    enable = true;
  };
  vpnNamespaces.wg = {
    portMappings = [{
      from = 9117;
      to = 9117;
    }];
  };
  systemd.services.jackett.vpnconfinement = {
    enable = true;
    vpnnamespace = "wg";
  };
  services.caddy.virtualHosts = {
    "jellyfin.brusapa.com".extraConfig = ''
      reverse_proxy http://localhost:8096
    '';
    "torrent.brusapa.com".extraConfig = ''
      reverse_proxy http://localhost:${toString config.nixarr.transmission.uiPort}
    '';
    "usenet.brusapa.com".extraConfig = ''
      reverse_proxy http://localhost:${toString config.nixarr.sabnzbd.guiPort}
    '';
    "radarr.brusapa.com".extraConfig = ''
      reverse_proxy http://localhost:${toString config.nixarr.radarr.port}
    '';
    "sonarr.brusapa.com".extraConfig = ''
      reverse_proxy http://localhost:8989
    '';
    "bazarr.brusapa.com".extraConfig = ''
      reverse_proxy http://localhost:${toString config.nixarr.bazarr.port}
    '';
    "lidarr.brusapa.com".extraConfig = ''
      reverse_proxy http://localhost:${toString config.nixarr.lidarr.port}
    '';
    "prowlarr.brusapa.com".extraConfig = ''
      reverse_proxy http://localhost:${toString config.nixarr.prowlarr.port}
    '';
    "jellyserr.brusapa.com".extraConfig = ''
      reverse_proxy http://localhost:${toString config.nixarr.jellyseerr.port}
    '';
    "jackett.brusapa.com".extraConfig = ''
      reverse_proxy http://192.168.15.1:${toString config.services.jackett.port}
    '';
  };
}
