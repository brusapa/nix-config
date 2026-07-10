{
  den.aspects.sun.nixos = 
    { config, ... }:
    {
      virtualisation.oci-containers.containers.brother-scanner = {
        image = "ghcr.io/philippmundhenk/brotherscannerdocker:v1.1.1";

        ports = [
          "54925:54925/udp" # For scanner tools
          "54921:54921" # For scanner tools
          "161:161/udp" # For scanner tools
        ];

        volumes = [
          "${config.services.paperless.consumptionDir}:/scans"
        ];

        environment = {
          "NAME" = "Estudio";
          "MODEL" = "MFC-L2710DW";
          "IPADDRESS" = "10.80.0.30";
          "UID" = toString config.users.users.${config.services.paperless.user}.uid;
          "GID" = toString config.users.groups.${config.services.paperless.user}.gid;
          "TZ" = "Europe/Madrid";
          "HOST_IPADDRESS" = "10.80.0.15";
        };
      };
    };
}
