{ lib, ... }:

{
  options.hosts = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule ({ name, ... }: {
      options = {
        system = lib.mkOption {
          type = lib.types.str;
          default = "x86_64-linux";
          description = "System type for host ${name}";
        };

        users = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [];
          description = "Home-manager users on host ${name}";
        };
      };
    }));
    default = {};
    description = "Host definitions (system + home-manager users)";
  };

  config.hosts = {
    sun = {
      users = [ "bruno" ];
    };

    mars = {
      users = [ "bruno" "gurenda" ];
    };

    mercury = {
      users = [ "bruno" "gurenda" ];
    };

    wsl = {
      users = [ "bruno" ];
    };

    rpi-landabarri = {
      system = "aarch64-linux";
      users = [ "bruno" ];
    };

    whale = {
      users = [ "bruno" ];
    };
  };
}