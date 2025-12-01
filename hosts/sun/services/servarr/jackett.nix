{ lib, ... }:
let
  vars = {
    config-path = "/var/lib/jackett/.config";
    port = 9117;
    version = "0.24.372";
  };
in {

  systemd.tmpfiles.rules = [
    "d ${vars.config-path} 0750 root root -"
  ];

  virtualisation.oci-containers.containers = {
    servarr-vpn.ports = lib.mkAfter [ "${toString vars.port}:${toString vars.port}/tcp" ];

    jackett = {
      image = "linuxserver/jackett:${vars.version}";

      volumes = [
        "${vars.config-path}:/config"
      ];

      environment = {
        TZ   = "Europe/Madrid";
      };

      dependsOn = [ "servarr-vpn" ];

      extraOptions = [
        "--network=container:servarr-vpn"
      ];
    };
  };

  services.caddy.virtualHosts."jackett.brusapa.com".extraConfig = ''
    reverse_proxy http://localhost:${toString vars.port}
  '';
}
