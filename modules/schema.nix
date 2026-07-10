{ lib, ... }:
{
  den.schema.host = { host, lib, ... }: {
    options = {
      role = lib.mkOption {
        type = lib.types.enum [ "server" "workstation" ];
        default = "server";
        description = "Define the main intended usage of the host";
      };
      swapSizeGiB = lib.mkOption {
        type = lib.types.int;
        description = "Swapfile size in GiB for this host";
      };
    };
  };
}