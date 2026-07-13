{
  den.aspects.sun.nixos =
    { config, ... }:
    let
      vars = {
        config-path = "/var/lib/gluetun";
        version = "v3.41.1";
      };
    in
    {
      # Import the needed secrets
      sops = {
        secrets = {
          "servarr-gluetun/wireguard-private-key" = {
            sopsFile = ../../secrets.yaml;
          };
        };
        templates."servarr-vpn-secrets.env" = {
          content = ''
            WIREGUARD_PRIVATE_KEY=${config.sops.placeholder."servarr-gluetun/wireguard-private-key"}
          '';
        };
      };

      systemd.tmpfiles.rules = [
        "d ${vars.config-path} 0750 root root -"
      ];

      virtualisation.oci-containers.containers.servarr-vpn = {
        image = "qmcgaw/gluetun:${vars.version}";

        extraOptions = [
          "--cap-add=net_admin"
        ];

        devices = [
          "/dev/net/tun:/dev/net/tun"
        ];

        volumes = [
          "${vars.config-path}:/gluetun"
        ];

        environment = {
          TZ = "Europe/Madrid";
          VPN_SERVICE_PROVIDER = "protonvpn";
          VPN_TYPE = "wireguard";
          PORT_FORWARD_ONLY = "on";
          VPN_PORT_FORWARDING = "on";
        };

        environmentFiles = [
          config.sops.templates."servarr-vpn-secrets.env".path
        ];
      };
    };
}
