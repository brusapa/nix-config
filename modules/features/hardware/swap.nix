{ den, ... }:
{
  den.aspects.swap = { host, ... }: {
    nixos = { ... }: {
      swapDevices = [
        {
          device = "/var/lib/swapfile";
          size = host.swapSizeGiB * 1024;
        }
      ];
      zramSwap.enable = true;
    };
  };
}
