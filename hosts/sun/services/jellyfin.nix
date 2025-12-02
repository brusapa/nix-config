{ inputs, config, ... }:
{
  # Import the needed secrets
  sops = {
    secrets = {
      "jellyfin/admin-password" = {
        sopsFile = ../secrets.yaml;
        owner = config.services.jellyfin.user;
        group = config.services.jellyfin.group;
      };
      "jellyfin/bruno-password" = {
        sopsFile = ../secrets.yaml;
        owner = config.services.jellyfin.user;
        group = config.services.jellyfin.group;
      };
      "jellyfin/gurenda-password" = {
        sopsFile = ../secrets.yaml;
        owner = config.services.jellyfin.user;
        group = config.services.jellyfin.group;
      };
      "jellyfin/casa-password" = {
        sopsFile = ../secrets.yaml;
        owner = config.services.jellyfin.user;
        group = config.services.jellyfin.group;
      };
      "jellyfin/stitch-password" = {
        sopsFile = ../secrets.yaml;
        owner = config.services.jellyfin.user;
        group = config.services.jellyfin.group;
      };
      "jellyfin/sonarr-apikey" = {
        sopsFile = ../secrets.yaml;
        owner = config.services.jellyfin.user;
        group = config.services.jellyfin.group;
      };
      "jellyfin/jellyserr-apikey" = {
        sopsFile = ../secrets.yaml;
        owner = config.services.jellyfin.user;
        group = config.services.jellyfin.group;
      };
    };
  };

  imports = [
    inputs.declarative-jellyfin.nixosModules.default
  ];

  services.declarative-jellyfin = {
    system = {
      serverName = "sun";
      # Use Hardware Acceleration for trickplay image generation
      trickplayOptions = {
        enableHwAcceleration = true;
        enableHwEncoding = true;
      };
      UICulture = "en-US";
    };
    users = {
      admin = {
        mutable = false; # overwrite user settings
        permissions.isAdministrator = true;
        hashedPasswordFile = config.sops.secrets."jellyfin/admin-password".path;
      };
      bruno = {
        hashedPasswordFile = config.sops.secrets."jellyfin/bruno-password".path;
      };
      gurenda = {
        hashedPasswordFile = config.sops.secrets."jellyfin/gurenda-password".path;
      };
      casa = {
        hashedPasswordFile = config.sops.secrets."jellyfin/casa-password".path;
      };
      stitch = {
        hashedPasswordFile = config.sops.secrets."jellyfin/stitch-password".path;
      };
    };
    libraries = {
      Peliculas = {
        enabled = true;
        contentType = "movies";
        preferredMetadataLanguage = "es";
        pathInfos = ["/zstorage/media/library/movies"];
      };
      Series = {
        enabled = true;
        contentType = "tvshows";
        preferredMetadataLanguage = "es";
        pathInfos = ["/zstorage/media/library/shows"];
      };
    };
    encoding = {
      enableHardwareEncoding = true;
      hardwareAccelerationType = "qsv";
      enableDecodingColorDepth10Hevc = true;
      enableDecodingColorDepth10HevcRext = true;
      enableDecodingColorDepth10Vp9 = true;
      enableDecodingColorDepth12HevcRext = true;
      enableTonemapping = true;
      enableVppTonemapping = true;
      allowHevcEncoding = false;
      allowAv1Encoding = false;
      hardwareDecodingCodecs = [ # enable the codecs your system supports
        "h264"
        "hevc"
        "mpeg2video"
        "vc1"
        "vp9"
        "av1"
      ];
    };
    apikeys = {
      sonarr.keyPath = config.sops.secrets."jellyfin/sonarr-apikey".path;
      jellyserr.keyPath = config.sops.secrets."jellyfin/jellyserr-apikey".path;
    };
    network = {
      baseUrl = "https://jellyfin.brusapa.com";
    };
    openFirewall = true;
  };
}