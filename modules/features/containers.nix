{
  den.aspects.containers.nixos = { lib, config, ... }: {

    options.oci-containers.gatewayIp = lib.mkOption {
      type = lib.types.str;
      default = "10.88.0.1";
      description = "Default gateway for oci-containers network.";
    };

    config = {
      virtualisation = {
        containers.enable = true;
        podman = {
          enable = true;
          dockerCompat = true;
          dockerSocket.enable = true;
          defaultNetwork.settings = {
            dns_enabled = true;
            subnets = [{
              gateway = config.oci-containers.gatewayIp;
              subnet = "10.88.0.0/16";
            }];
          };
        };
      };
    };
  };
}
