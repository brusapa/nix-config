{ config, ... }:
{
  sops = {
    secrets = {
      "jellyfin/jellar-api-key" = {
        sopsFile = ../../secrets.yaml;
      };
      "jellyfin/bruno-password" = {
        sopsFile = ../../secrets.yaml;
      };
      "jellyfin/casa-password" = {
        sopsFile = ../../secrets.yaml;
      };
      "jellyfin/stitch-password" = {
        sopsFile = ../../secrets.yaml;
      };
      "jellyfin/aitas-password" = {
        sopsFile = ../../secrets.yaml;
      };
    };
  };


  services.jellar = {
    enable = true;
    user = "jellyfin";
    group = "jellyfin";
    bootstrap = {
      enable = true;
      apiKeyFile = config.sops.secrets."jellyfin/jellar-api-key".path;
    };
    config = {
      base_url = "https://jellyfin.brusapa.com";
      startup.completeStartupWizard = true;
      system = {
        enableMetrics = true;
        trickplayOptions = {
          enableHwAcceleration = true;
          enableHwEncoding = true;
        };
      };
      encoding = {
        enableHardwareEncoding = true;
        hardwareAccelerationType = "qsv";
        qsvDevice = "/dev/dri/by-path/pci-0000:00:02.0-render";
        hardwareDecodingCodecs = [
          "h264"
          "hevc"
          "mpeg2video"
          "vc1"
          "vp9"
          "av1"
        ];
        enableDecodingColorDepth10Hevc = true;
        enableDecodingColorDepth10Vp9 = true;
        enableDecodingColorDepth10HevcRext = true;
        enableDecodingColorDepth12HevcRext = true;
        allowHevcEncoding = false;
        allowAv1Encoding = false;
      };
      library = {
        virtualFolders = [
          {
            name = "Peliculas";
            collectionType = "movies";
            libraryOptions.pathInfos = [
              "/zstorage/media/library/movies"
            ];
          }
          {
            name = "Series";
            collectionType = "tvshows";
            libraryOptions.pathInfos = [
              "/zstorage/media/library/shows"
            ];
          }
        ];
      };
      users = [
        {
          name = "bruno";
          policy.isAdministrator = true;
          passwordFile = config.secrets."jellyfin/bruno-password".path;
        }
        {
          name = "aitas";
          passwordFile = config.secrets."jellyfin/aitas-password".path;
        }
        {
          name = "casa";
          passwordFile = config.secrets."jellyfin/casa-password".path;
        }
        {
          name = "stitch";
          passwordFile = config.secrets."jellyfin/stitch-password".path;
        }
      ];
    };
  };
}