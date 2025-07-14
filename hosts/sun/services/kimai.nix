{ inputs, config, pkgs, ... }:
{

  environment.systemPackages = [
    inputs.pangolin-newt.packages.x86_64-linux.pangolin-newt
  ];

  # Import the needed secrets
  sops = {
    secrets = {
      "kimai/database-password" = {
        sopsFile = ../secrets.yaml;
      };
      "kimai/database-root-password" = {
        sopsFile = ../secrets.yaml;
      };
      "kimai/admin-email" = {
        sopsFile = ../secrets.yaml;
      };
      "kimai/admin-password" = {
        sopsFile = ../secrets.yaml;
      };
    };
    templates."kimai-secrets.env" = {
      content = ''
        MYSQL_DATABASE=kimai
        MYSQL_USER=kimaiuser
        MYSQL_PASSWORD=${config.sops.placeholder."kimai/database-password"}
        MYSQL_ROOT_PASSWORD=${config.sops.placeholder."kimai/database-root-password"}
        ADMINMAIL=${config.sops.placeholder."kimai/admin-email"}
        ADMINPASS=${config.sops.placeholder."kimai/admin-password"}
        DATABASE_URL=mysql://kimaiuser:${config.sops.placeholder."kimai/database-password"}@kimai-db/kimai?charset=utf8mb4&serverVersion=8.3.0
      '';
    };
  };

  virtualisation = {
    oci-containers.containers = {
      kimai-db = {
        volumes = [ 
          "db:/var/lib/mysql" 
        ];
        environmentFiles = [
          config.sops.templates."kimai-secrets.env".path
        ];
        # Note: The image will not be updated on rebuilds, unless the version label changes
        image = "mysql:8.3";
        cmd = [ "--default-storage-engine" "innodb" ];
        networks = [
          "kimai-net"
        ];
      };

      kimai = {
        volumes = [
          "data:/opt/kimai/var/data"
          "plugins:/opt/kimai/var/plugins"
        ];
        environmentFiles = [
          config.sops.templates."kimai-secrets.env".path
        ];
        # Note: The image will not be updated on rebuilds, unless the version label changes
        image = "kimai/kimai2:apache";
        ports = [ 
          "8001:8001" # Web interface
        ];
        networks = [
          "kimai-net"
        ];
      };
    };
  };

  systemd.services.podman-create-kimai-network = {
    serviceConfig.Type = "oneshot";
    wantedBy = ["podman-kimai-db.service"];
    path = [ pkgs.podman ];
    script = ''
      podman network exists kimai-net || podman network create kimai-net
    '';
  };

  services.caddy.virtualHosts."kimai.brusapa.com".extraConfig = ''
    reverse_proxy http://localhost:8001
  '';
}