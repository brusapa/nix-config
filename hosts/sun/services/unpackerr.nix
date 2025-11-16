{ config, ... }:
let
  configurationDirectory = "/var/lib/unpackerr/.config";
in {
  # Import the needed secrets
  sops = {
    secrets = {
      "unpackerr/sonarr-api-key" = {
        sopsFile = ../secrets.yaml;
      };
      "unpackerr/radarr-api-key" = {
        sopsFile = ../secrets.yaml;
      };
      "unpackerr/lidarr-api-key" = {
        sopsFile = ../secrets.yaml;
      };
    };
    templates."unpackerr-secrets.env" = {
      content = ''
        UN_SONARR_0_API_KEY=${config.sops.placeholder."unpackerr/sonarr-api-key"}
        UN_RADARR_0_API_KEY=${config.sops.placeholder."unpackerr/radarr-api-key"}
        UN_LIDARR_0_API_KEY=${config.sops.placeholder."unpackerr/lidarr-api-key"}
      '';
    };
  };

  # Create configuration directory
  systemd.tmpfiles.rules = [
    "d ${configurationDirectory} 0755 ${config.users.users.qbittorrent.name} ${config.users.groups.media.name}"
  ];

  virtualisation.oci-containers.containers.unpackerr = {
    user = "${ toString config.users.users.qbittorrent.uid }:${ toString config.users.groups.media.gid }";

    image = "golift/unpackerr:latest";

    volumes = [
      "${configurationDirectory}:/config"
      "/zstorage/media/torrents:/downloads"
    ];

    environmentFiles = [
      config.sops.templates."unpackerr-secrets.env".path
    ];

    environment = {
      TZ = "Europe/Madrid";
      ## Global Settings
      UN_DEBUG = "false";
      UN_QUIET = "false";
      UN_ERROR_STDERR = "false";
      UN_ACTIVITY = "false";
      UN_LOG_QUEUES = "1m";
      UN_LOG_FILE = "/config/unpackerr.log";
      UN_LOG_FILES = "10";
      UN_LOG_FILE_MB = "10";
      UN_LOG_FILE_MODE = "0600";
      UN_INTERVAL = "2m";
      UN_START_DELAY = "1m";
      UN_RETRY_DELAY = "5m";
      UN_MAX_RETRIES = "3";
      UN_PARALLEL = "1";
      UN_FILE_MODE = "0664";
      UN_DIR_MODE = "0775";
      ## Web Server
      UN_WEBSERVER_METRICS = "false";
      UN_WEBSERVER_LISTEN_ADDR = "0.0.0.0:5656";
      UN_WEBSERVER_LOG_FILE = "";
      UN_WEBSERVER_LOG_FILES = "10";
      UN_WEBSERVER_LOG_FILE_MB = "10";
      UN_WEBSERVER_SSL_CERT_FILE = "";
      UN_WEBSERVER_SSL_KEY_FILE = "";
      UN_WEBSERVER_URLBASE = "/";
      UN_WEBSERVER_UPSTREAMS = "";
      ## Folder Settings
      UN_FOLDERS_INTERVAL = "1s";
      UN_FOLDERS_BUFFER = "20000";
      ## Sonarr Settings
      UN_SONARR_0_URL = "https://sonarr.brusapa.com";
      UN_SONARR_0_PATHS_0 = "/downloads/sonarr";
      UN_SONARR_0_PROTOCOLS = "torrent";
      UN_SONARR_0_TIMEOUT = "10s";
      UN_SONARR_0_DELETE_DELAY = "5m";
      UN_SONARR_0_DELETE_ORIG = "false";
      UN_SONARR_0_SYNCTHING = "false";
      ## Radarr Settings
      UN_RADARR_0_URL = "https://radarr.brusapa.com";
      UN_RADARR_0_PATHS_0 = "/downloads/radarr";
      UN_RADARR_0_PROTOCOLS = "torrent";
      UN_RADARR_0_TIMEOUT = "10s";
      UN_RADARR_0_DELETE_DELAY = "5m";
      UN_RADARR_0_DELETE_ORIG = "false";
      UN_RADARR_0_SYNCTHING = "false";
      ## Lidarr Settings
      UN_LIDARR_0_URL = "http://lidarr.brusapa.com";
      UN_LIDARR_0_PATHS_0 = "/downloads/lidarr";
      UN_LIDARR_0_PROTOCOLS = "torrent";
      UN_LIDARR_0_TIMEOUT = "10s";
      UN_LIDARR_0_DELETE_DELAY = "5m";
      UN_LIDARR_0_DELETE_ORIG = "false";
      UN_LIDARR_0_SYNCTHING = "false";
    };
  };
}
