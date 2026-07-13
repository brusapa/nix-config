{
  den.aspects.wallaos.nixos =
    { lib, config, ... }:
    let
      inherit (lib) mkOption types;
      cfg = config.wallaos;
    in
    {
      options.wallaos = {
        port = mkOption {
          type = types.port;
          default = 8282;
        };

        subdomain = mkOption {
          type = types.str;
          default = "wallaos";
          description = "Domain for wallaos";
        };
      };

      config = {

        virtualisation.oci-containers.containers.wallaos = {
          volumes = [
            "wallaos-db:/var/www/html/db"
            "wallaos-logos:/var/www/html/images/uploads/logos"
          ];
          environment.TZ = "Europe/Madrid";
          image = "ghcr.io/ellite/wallos:4.9.6";

          ports = [
            "${toString cfg.port}:80/tcp"
          ];
        };

        reverseProxy.hosts.${cfg.subdomain}.httpPort = cfg.port;

      };
    };
}
