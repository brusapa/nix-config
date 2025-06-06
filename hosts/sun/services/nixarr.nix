{ inputs, pkgs, config, ... }:

{
  imports = [
    inputs.nixarr.nixosModules.default
  ];

  # Enable HW acceleration for jellyfin
  systemd.services.jellyfin.environment.LIBVA_DRIVER_NAME = "iHD";
  environment.sessionVariables = { LIBVA_DRIVER_NAME = "iHD"; };
  hardware = {
    enableAllFirmware = true;
    intel-gpu-tools.enable = true;
    graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver
        vaapiVdpau
        intel-compute-runtime
        vpl-gpu-rt # QSV on 11th gen or newer
        intel-ocl
      ];
    };
  };

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
      owner = "torrenter";
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
    };

    transmission = {
      enable = true;
      extraAllowedIps = [
        "10.80.0.* "
      ];
      credentialsFile = config.sops.templates."transmission-credentials".path;
      extraSettings = {
        rpc-authentication-required = true;
      };
      vpn.enable = true;
      openFirewall = true;
      peerPort = 56258; # Set this to the port forwarded by your VPN
    };

    sabnzbd = {
      enable = true;
      vpn.enable = true;
      openFirewall = true;
      whitelistHostnames = [
        "usenet.brusapa.com"
      ];
      whitelistRanges = [
        "10.80.0.0/24"
        "192.168.0.0/16"
      ];
    };

    # It is possible for this module to run the *Arrs through a VPN, but it
    # is generally not recommended, as it can cause rate-limiting issues.
    bazarr.enable = true;
    prowlarr.enable = true;
    radarr.enable = true;
    sonarr.enable = true;
    jellyseerr.enable = true;
  };

  services.jackett = {
    enable = true;
    openFirewall = true;
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
      reverse_proxy http://127.0.0.1:8096
    '';
    "torrent.brusapa.com".extraConfig = ''
      reverse_proxy http://127.0.0.1:9091
    '';
    "usenet.brusapa.com".extraConfig = ''
      reverse_proxy http://127.0.0.1:8080
    '';
    "radarr.brusapa.com".extraConfig = ''
      reverse_proxy http://127.0.0.1:7878
    '';
    "sonarr.brusapa.com".extraConfig = ''
      reverse_proxy http://127.0.0.1:8989
    '';
    "bazarr.brusapa.com".extraConfig = ''
      reverse_proxy http://127.0.0.1:6767
    '';
    "prowlarr.brusapa.com".extraConfig = ''
      reverse_proxy http://127.0.0.1:9696
    '';
    "jellyserr.brusapa.com".extraConfig = ''
      reverse_proxy http://127.0.0.1:5055
    '';
    "jackett.brusapa.com".extraConfig = ''
      reverse_proxy http://192.168.15.1:9117
    '';
  };
}
