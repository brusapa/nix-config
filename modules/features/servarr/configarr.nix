{ den, inputs, ... }:
{
  flake-file.inputs = {
    configarr.url = "github:raydak-labs/configarr";
  };

  den.aspects.configarr = {
    includes = [
      den.aspects.reverse-proxy
    ];

    nixos = { config, ... }: {
      imports = [
        inputs.configarr.nixosModules.default
      ];

      # Import the needed secrets
      sops = {
        secrets = {
          "servarr/radarr/apikey" = { };
          "servarr/qbittorrent/password" = { };
        };
        templates.configarr-ev = {
          content = ''
            CONFIGARR_ENABLE_MERGE=true
            CONFIGARR_ENFORCE_CONFIG_VALIDATION=true
            LOG_LEVEL=debug
            LOG_STACKTRACE=true
            RADARR_API_KEY=${config.sops.placeholder."servarr/radarr/apikey"}
            QBITTORRENT_PASSWORD=${config.sops.placeholder."servarr/qbittorrent/password"}
          '';
          inherit (config.services.configarr) group;
          owner = config.services.configarr.user;
        };
      };

      services.configarr = {
        enable = true;
        environmentFile = "${config.sops.templates.configarr-ev.path}";
        config =
          # yaml
          ''
            x-download-clients:
              # Define an anchor for shared instance
              qb_base: &qb_base
                name: "qBittorrent"
                type: qbittorrent
                enable: true
                priority: 1
                remove_completed_downloads: true
                remove_failed_downloads: true
                # YAML does a shallow merge, thus we must declare another anchor for the nested dictionary if we plan to override values in it
                fields: &qb_fields
                  host: qbittorrent.${config.reverseProxy.baseDomain}
                  port: 443
                  use_ssl: true
                  url_base: ""
                  api_key: ""
                  username: bruno
                  password: !env QBITTORRENT_PASSWORD

            radarr:
              radarr_instance:
                api_key: !env RADARR_API_KEY
                base_url: https://radarr.${config.reverseProxy.baseDomain}
                media_naming:
                  folder: default
                  movie:
                    rename: true
                    standard: standard
                root_folders:
                  - /zstorage/media/library/movies
                download_clients:
                  data:
                    - <<: *qb_base
                      fields:
                        <<: *qb_fields
                        movie_imported_category: radarr
                  update_password: false
                  delete_unmanaged:
                    enabled: true
                  config:
                    enable_completed_download_handling: true
                    auto_redownload_failed: false
                  remote_paths:
                    - host: "qbittorrent.${config.reverseProxy.baseDomain}"
                      remote_path: "/downloads"
                      local_path: "/zstorage/media/torrents"

          '';
      };
    };

  };
}
