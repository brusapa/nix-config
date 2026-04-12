{ lib, config, ... }:
let
  inherit (lib) mkIf mkOption  mkEnableOption types;
  cfg = config.frigate;
  serviceName = "fileBrowserQuantum";
in
{
  options.fileBrowserQuantum = {
    enable = mkEnableOption "Enable FileBrowser Quantum";

    subdomain = mkOption {
      type = types.str;
      default = "explorador";
    };

    version = mkOption {
      type = types.str;
      default = "latest";
    };

    port = mkOption {
      type = types.port;
      default = 8900;
    };

    files-path = mkOption {
      type = types.path;
      default = "/var/lib/frigate/media";
      description = "Path to files to be served by FileBrowser Quantum";
    };
  };

  config = mkIf cfg.enable {

    users.groups.${serviceName} = {};
    users.users.${serviceName} = {
      group = "${serviceName}";
      isSystemUser = true;
      groups = [ "users" ];
    };

    # Ensure directories exist with sane permissions
    systemd.tmpfiles.rules = [
      "d /var/lib/${serviceName} 0775 ${serviceName} ${serviceName} -"
    ];

    virtualisation.oci-containers.containers.fileBrowserQuantum = {
      user = "${serviceName}:users";

      volumes = [
        "/var/lib/${serviceName}:/home/filebrowser/data"
        "${cfg.files-path}:/files"
      ];
      
      environment = {
        TZ = "Europe/Madrid";
        FILEBROWSER_CONFIG = "data/config.yaml";
      };

      image = "gtstef/filebrowser:${cfg.version}";

      ports = [
        "${toString cfg.port}:80/tcp"
      ];
    };

    reverseProxy.hosts.${cfg.subdomain}.httpsPort = cfg.port;

  };
}
